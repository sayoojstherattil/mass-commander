#!/bin/bash

echo "executing package installer"

commands_to_run_file_appender() {
	req_command="$1"

	echo "$req_command" >> $runtime_files_dir/commands-to-run
}

other_files_to_tarring_area_copier() {
	cp /root/mass-commander/permanent-files/temp-sources-file $runtime_files_dir/files-to-tar
	cp $runtime_files_dir/packages-to-install $runtime_files_dir/files-to-tar
}

local_repo_files_to_tarring_area_copier() {
	ls $runtime_files_dir/local-repo-creation >> $runtime_files_dir/files-in-local-repo

	while read local_repo_file_name; do
		cp $runtime_files_dir/local-repo-creation/$local_repo_file_name root/mass-commander/runtime-files/files-tarring-area
	done<$runtime_files_dir/files-in-local-repo
}

local_repo_creator() {
	dpkg-scanpackages $runtime_files_dir/local-repo-creation /dev/null | gzip -9c | tee $runtime_files_dir/local-repo-creation/Packages.gz > /dev/null
}

fetched_deb_files_to_local_repo_creation_dir_placer() {
	while read deb_file_name; do
		cp /var/cache/apt/archives/$deb_file_name $runtime_files_dir/local-repo-creation
	done<$runtime_files_dir/fetched-deb-files
}

local_repo_creation_dir_ensurer() {
	if [ -d $runtime_files_dir/local-repo-creation ]; then
		rm -r $runtime_files_dir/local-repo-creation
		mkdir $runtime_files_dir/local-repo-creation
	else
		mkdir $runtime_files_dir/local-repo-creation
	fi
}

required_deb_files_fetcher_and_identifier() {
	#current_files_in_archive_fetcher
	ls /var/cache/apt/archives > $runtime_files_dir/files-in-archive-old

	apt-get install --download-only $(cat $runtime_files_dir/packages-to-install) -y

	#current files_in_archive_fetcher
	ls /var/cache/apt/archives > $runtime_files_dir/files-in-archive-new

	#new_files_in_archive_identifier
	cat $runtime_files_dir/files-in-archive-new | grep -v -f $runtime_files_dir/files-in-archive-old > $runtime_files_dir/fetched-deb-files
}

required_package_names_fetcher() {
	echo "enter names of packages one by one: "

	while read package_name; do
		echo "$package_name" >> $runtime_files_dir/packages-to-install
	done
}

required_package_names_fetcher
required_deb_files_fetcher_and_identifier
local_repo_creation_dir_ensurer
fetched_deb_files_to_local_repo_creation_dir_placer
local_repo_creator
local_repo_files_to_tarring_area_copier
other_files_to_tarring_area_copier

#appending commands to run to the required file
commands_to_run_file_appender 'mv /etc/apt/sources.list /etc/apt/sources.list.bak'
commands_to_run_file_appender 'cp $runtime_files_dir/files-from-server/sources.list /etc/apt/sources.list'
commands_to_run_file_appender 'apt-get update'
commands_to_run_file_appender 'apt-get install $(cat /root/mass-commander/files-from-server/packages-to-install)'
commands_to_run_file_appender 'rm /etc/apt/sources.list'
commands_to_run_file_appender 'mv /etc/apt/sources.list.bak /etc/apt/sources.list'

#commander caller
commander.sh
