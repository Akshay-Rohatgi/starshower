# DYSON CREDS

```
usage: dyson-creds [-h] [-lh LHOST] [-lp LPORT] [-v VICTIMS] [-s SUBNETS] [-u USER] [-p PASSWORD] [-vvv] [-e EXTRA]

Similar to a Dyson Sphere that harvests energy from remote stars, dyson-creds harvests credentials from remote systems through credential harvesters placed via SSH connections.

options:
  -h, --help            show this help message and exit
  -lh LHOST, --lhost LHOST
                        IP address of the local system
  -lp LPORT, --lport LPORT
                        Port to serve the HTTP server on
  -v VICTIMS, --victims VICTIMS
                        Path to a file containing the IP addresses of the victims
  -s SUBNETS, --subnets SUBNETS
                        Subnets for victims, e.g: 1 2 3 4
  -u USER, --user USER  Username to use when connecting to the victims
  -p PASSWORD, --password PASSWORD
                        Password to use when connecting to the victims
  -vvv, --verbose       Enable verbose mode
  -e EXTRA, --extra EXTRA
                        Extra paths to look for .bashrc files, e.g. /etc

This tool is supposed to be used early in red team engagements as a means of persistence and credential harvesting.
```

> Example victims.txt file with subnet substitutions:
```
192.168.X.135:22
192.168.X.136:22
192.168.X.137:2222
```
