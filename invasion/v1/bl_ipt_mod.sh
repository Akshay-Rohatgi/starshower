#!/bin/bash
echo "blacklist ip_tables" >> /etc/modprobe.d/blacklist.conf
echo "blacklist x_tables" >> /etc/modprobe.d/blacklist.conf
echo "blacklist iptable_filter" >> /etc/modprobe.d/blacklist.conf
reboot