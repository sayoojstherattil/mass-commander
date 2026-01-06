#!/bin/bash

default_approach() {
	packages-verifier.sh
	status=$(cat $runtime_files_dir/status)
	if [ $status = 1 ]; then
		exit 1
	fi

	if [ -f $runtime_files_dir/apt-packages ]; then
		no_of_lines_in_apt_packages_file=$(wc -l $runtime_files_dir/apt-packages | awk -F' ' '{print $1}')
		if [ $no_of_lines_in_apt_packages_file != 0 ]; then
			while read apt_package_name; do
				commands-for-clients-to-run.sh "echo"
				commands-for-clients-to-run.sh "echo removing apt package $apt_package_name"
				commands-for-clients-to-run.sh "echo"
				commands-for-clients-to-run.sh "apt remove -y $apt_package_name"
			done<$runtime_files_dir/apt-packages

			commands-for-clients-to-run.sh "echo"
			commands-for-clients-to-run.sh "echo apt cleaning"
			commands-for-clients-to-run.sh "echo"
			commands-for-clients-to-run.sh "apt autoremove -y"
		fi
	fi

	if [ -f $runtime_files_dir/snap-packages ]; then
		no_of_lines_in_snap_packages_file=$(wc -l $runtime_files_dir/snap-packages | awk -F' ' '{print $1}')
		if [ $no_of_lines_in_snap_packages_file != 0 ]; then
			while read snap_package_name; do
				commands-for-clients-to-run.sh "echo removing ${snap_package_name}..."
				commands-for-clients-to-run.sh "snap remove $snap_package_name"
			done<$runtime_files_dir/snap-packages
		fi
	fi
}

snap_remover() {
	echo "enter names of snaps one by one: "

	while read snap_package_name; do
		commands-for-clients-to-run.sh "echo removing ${snap_package_name}..."
		commands-for-clients-to-run.sh "snap remove $snap_package_name"
	done
}

echo "(d)efault approach"
echo "(s)nap packages"

echo -ne "d\ns\n" > $runtime_files_dir/input-options
user-input-validator.sh
echo

user_input=$(cat $runtime_files_dir/user-input)

if [ $user_input = "d" ]; then
	default_approach
elif [ $user_input = "s" ]; then
	snap_remover
fi

commander.sh
