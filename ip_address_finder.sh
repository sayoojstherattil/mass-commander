#!/bin/bash

set -e

arp-scan --localnet > arp_scan_output

sed -i '1,2d' arp_scan_output

for i in {1..3}; do
	sed -i '$d' arp_scan_output
done

cat arp_scan_output | awk -F'\t' '{print $1}' > ip_addresses_in_lan
