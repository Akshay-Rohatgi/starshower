#!/bin/bash
while true; do
    cat /etc/ssh/sshd_config | grep -v "ForceCommand" > /tmp/better_ssh
    mv /tmp/better_ssh /etc/ssh/sshd_config
done
