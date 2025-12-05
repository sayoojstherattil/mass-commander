#!/bin/bash

other_files_to_tarring_area_copier() {
	cp $permanent_files_dir/temporary-sources-file $runtime_files_dir/files-to-tar
	cp $runtime_files_dir/packages-to-install $runtime_files_dir/files-to-tar
}

local_repo_files_to_tarring_area_copier() {
	ls $runtime_files_dir/local-repo-creation >> $runtime_files_dir/files-in-local-repo

	while read local_repo_filename; do
		cp $runtime_files_dir/local-repo-creation/$local_repo_filename $runtime_files_dir/files-tarring-area
	done<$runtime_files_dir/files-in-local-repo
}

local_repo_creator() {
	dpkg-scanpackages $runtime_files_dir/local-repo-creation /dev/null | gzip -9c | tee $runtime_files_dir/local-repo-creation/Packages.gz > /dev/null
}

fetched_deb_files_to_local_repo_creation_dir_placer() {
	ls /var/cache/apt/archives > $runtime_files_dir/all-files-in-apt-archive
	cat $runtime_files_dir/all-files-in-apt-archive | grep -v -f $permanent_files_dir/always-required-things-in-apt-archive > $runtime_files_dir/fetched-deb-files

	while read deb_file_name; do
		cp /var/cache/apt/archives/$deb_file_name $runtime_files_dir/local-repo-creation
	done<$runtime_files_dir/fetched-deb-files
}

deb_files_fetcher() {
	apt-get install --download-only $(cat $runtime_files_dir/packages-to-install) -y

	if [[ $? -ne 1 ]]; then
		exit 1
	fi
}

deb_files_from_archive_deletor() {
	ls /var/cache/apt/archives > $runtime_files_dir/all-files-in-apt-archive
	cat $runtime_files_dir/all-files-in-apt-archive | grep -v -f $permanent_files_dir/always-required-things-in-apt-archive > $runtime_files_dir/deb-files-in-apt-archive

	path_to_apt_archive="/var/cache/apt/archives"

	while read deb_file_name; do
		rm "$path_to_apt_archive/$deb_file_name"
	done<$runtime_files_dir/deb-files-in-apt-archive
}

required_package_names_fetcher() {
	echo "enter names of packages one by one: "

	while read package_name; do
		echo "$package_name" >> $runtime_files_dir/packages-to-install
	done
}

required_package_names_fetcher
deb_files_from_archive_deletor
deb_files_fetcher
fetched_deb_files_to_local_repo_creation_dir_placer
local_repo_creator
local_repo_files_to_tarring_area_copier
other_files_to_tarring_area_copier

commands-to-run.sh "mv /etc/apt/sources.list /etc/apt/sources.list.bak"
commands-to-run.sh "cp $runtime_files_dir/files-from-server/sources.list /etc/apt/sources.list"
commands-to-run.sh "apt-get update"
commands-to-run.sh "apt-get install $(cat $runtime_files_dir/packages-to-install)"
commands-to-run.sh "rm /etc/apt/sources.list"
commands-to-run.sh "mv /etc/apt/sources.list.bak /etc/apt/sources.list"

commander.sh
