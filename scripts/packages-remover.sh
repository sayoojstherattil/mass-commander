#!/bin/bash

echo "enter names of packages one by one: "

while read package_name; do
	echo "$package_name" >> $runtime_files_dir/packages-to-remove
done

echo "apt remove $(cat $runtime_files_dir/packages-to-remove) -y" > $runtime_files_dir/commands-for-client-to-run-as-root
echo "apt autoremove -y" >> $runtime_files_dir/commands-for-client-to-run-as-root

commander.sh
