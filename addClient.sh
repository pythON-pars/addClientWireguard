#!/usr/bin/env bash
#
# Script fot automatic add of users.
#

if [ "$EUID" -ne 0 ]; then
 echo "Please, run the script as root."
 exit 1
fi

read -p "Enter user name: " user_name
read -p "Set ip for client: " local_address_client

wg genkey | tee "${user_name}_privatekey" | wg pubkey | tee "${user_name}_publickey"

private_key=$(cat "${user_name}_privatekey")
public_key=$(cat "${user_name}_publickey")

cat << EOF >> "${user_name}.conf"
[Interface]
PrivateKey = ${private_key}
Address = ${local_address_client}/32
DNS = 

[Peer]
PublicKey = 
Endpoint = <you server ip address>:<port> 
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 20
EOF

cat << EOF >> /etc/wireguard/wg0.conf

[Peer]
PublicKey = ${public_key}
AllowedIPs = ${local_address_client}/32
EOF

systemctl restart wg-quick@wg0

chown <you user>:<you user> ${user_name}.conf

exit 0

### THE END ###
