#!/bin/bash

echo -ne "enter names of packages one by one: "

while read package_name; do
	echo "$package_name" >> $runtime_files_dir/packages-to-remove
done

echo 'apt remove $(cat /root/mass-commander/files-from-server/packages-to-remove) -y' > $runtime_files_dir/commands-to-run
echo "apt autoremove -y" >> $runtime_files_dir/commands-to-run

cp $runtime_files_dir/packages-to-remove $runtime_files_dir/files-to-tar

commander.sh
