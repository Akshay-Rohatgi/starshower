#!/usr/bin/env python
import argparse
import printer
import utils
import os

# GLOBALS
IP_USER_MAP = "conf/dominion.conf"
PASSWORDS_DB = "conf/passwords.db"
LOG_FILE = "log/dominion.log"
BINARY = "../coordinate/coordinate-macos"
WARNING = "WARNING"
SUCCESS = "SUCCESS"
ERROR = "ERROR"

def main() -> None:
    parser = argparse.ArgumentParser(description='Dominion. A python wrapper for "coordinate" to more effectively manage multiple Linux hosts.')

    parser.add_argument('-E', '--execute', help=f'Execute script on provided hosts: -E=/path/to/script.sh:192.168.220.12,192.168.220.13:arg1,arg2,arg3', type=str)
    parser.add_argument('-A', '--add', help=f'Add host to {IP_USER_MAP}: -A=192.168.220.12:root:password', type=str)
    parser.add_argument('-C', '--clear', help=f'Clear log file at {LOG_FILE}', action='store_true')
    parser.add_argument('-RUN', '--run', help=f'Run provided script on all hosts in {IP_USER_MAP}', type=str)

    args = parser.parse_args()

    if not os.path.exists(IP_USER_MAP):
        printer.message(f"{IP_USER_MAP} not found.", WARNING)
        utils.die(ERROR)
    
    if not os.path.exists(PASSWORDS_DB):
        printer.message(f"{PASSWORDS_DB} not found.", WARNING)
        utils.die(ERROR)
    
    if not os.path.exists(LOG_FILE):
        printer.message(f"{LOG_FILE} not found.", WARNING)
        utils.die(ERROR)

    if args.clear:
        utils.clean_log()

    if args.add:
        ip, username, password = args.add.split(':')[0], args.add.split(':')[1], args.add.split(':')[2]
        utils.add_host(ip, username, password)

    if args.run:
        utils.run_script_against_all_hosts(args.run)

    if args.execute:
        utils.execute(args.execute)

if __name__ == "__main__":
    utils.log("Dominion started")
    printer.print_banner()
    main()
