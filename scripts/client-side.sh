#!/bin/bash



server_ip=$(cat /root/mass-commander/permanent-files/server-ip)

mkdir $runtime_files_dir/
cd $runtime_files_dir/

sftp sftpuser@$server_ip <<EOF
get /data/files-from-server.tar.gz
exit
EOF

mkdir /root/mass-commander/files-from-server/
tar -xzf files-from-server.tar.gz -C /root/files-from-server

source /root/mass-commander/files-from-server/commands-to-run

rm -r /root/mass-commander/files-from-server/
rm -r $runtime_files_dir/
