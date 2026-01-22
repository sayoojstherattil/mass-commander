#!/bin/bash

ip_address="$1"

ssh -o StrictHostKeyChecking=no root@$ip_address "/root/mass-commander/scripts/client-side.sh > /root/mass-commander/runtime-files/client-side-output"
