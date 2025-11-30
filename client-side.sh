#!/bin/bash

set -e

server_ip=$(cat /$USER/mass-commander/permanent-files/server-ip)

mkdir /root/mass-commander/files-from-server/
cd /root/mass-commander/files-from-server/

sftp sftpuser@$server_ip <<EOF
get /data/files-from-server.tar.gz
exit
EOF

tar -xzf files-from-server.tar.gz -C /root/files-from-server

source /root/mass-commander/files-from-server/commands-to-run

rm -r /root/mass-commander/files-from-server/
