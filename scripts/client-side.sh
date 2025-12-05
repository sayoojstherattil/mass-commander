#!/bin/bash

directory_ensurer() {
	dir_name="$1"

	if [ -d $dir_name ]; then
		rm -r $dir_name
		mkdir $dir_name
	else
		mkdir $dir_name
	fi
}

necessary_directories_ensurer() {
	directory_ensurer "$runtime_files_dir"
	directory_ensurer "$runtime_files_dir/files-from-server"
}

script_necessary_variables_changer() {
	export runtime_files_dir="/root/mass-commander/runtime-files"
	export permanent_files_dir="/root/mass-commander/permanent-files"
}

script_necessary_variables_changer
necessary_directories_ensurer

server_ip=$(cat $permanent_files_dir/server-ip)

cd $runtime_files_dir
sftp sftpuser@$server_ip <<EOF
get /data/files-from-server.tar.gz
exit
EOF
cd -

tar -xzf $runtime_files_dir/files-from-server.tar.gz -C $runtime_files_dir/files-from-server

source $runtime_files_dir/files-from-server/commands-to-run
$runtime_files_dir/files-from-server/app-opener.sh

rm -r $runtime_files_dir/
