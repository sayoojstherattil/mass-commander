#!/bin/bash

echo "enter names of packages one by one: "

while read package_name; do
	echo "$package_name" >> $runtime_files_dir/packages-to-remove
done

commands-for-clients-to-run.sh "apt remove $(cat $runtime_files_dir/packages-to-remove) -y"
commands-for-clients-to-run.sh "apt autoremove -y"

commander.sh
