#!/bin/bash

ip_address="$1"

ssh -o StrictHostKeyChecking=no root@$ip_address "/root/mass-commander/scripts/client-side.sh" >$runtime_files_dir/ssh-output-of-${ip_address} 2>&1
