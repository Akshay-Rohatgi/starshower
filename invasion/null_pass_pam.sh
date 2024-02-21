#!/bin/bash
if [ -d "/etc/pam.d/password-auth" ]; then
    sed -ie "s/nullok_secure/nullok/g" /etc/pam.d/password-auth
    sed -ie "s/try_first_pass//g" /etc/pam.d/password-auth
fi

if [ -d "/etc/pam.d/common-auth" ]; then
    sed -ie "s/nullok_secure/nullok/g" /etc/pam.d/common-auth
fi