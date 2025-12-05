#!/bin/bash

echo -ne "enter names of packages one by one: "

while read package_name; do
	echo "$package_name" >> $runtime_files_dir/packages-to-remove
done

commands-to-run.sh "apt-get remove $(cat $runtime_files_dir/files-from-server/packages-to-remove) -y"
commands-to-run.sh "apt-get autoremove -y"
files-to-tar.sh "$runtime_files_dir/packages-to-remove"

commander.sh
