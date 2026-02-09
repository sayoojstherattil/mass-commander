#!/bin/bash

#----------------------------------------------------------------------
# package verification
#----------------------------------------------------------------------
packages-verifier.sh

status=$(cat $runtime_files_dir/status)

if [ $status = 1 ]; then
	exit 1
fi

#----------------------------------------------------------------------
# remove apt if any
#----------------------------------------------------------------------
if [ -f $runtime_files_dir/apt-packages ]; then
	commands-for-clients-to-run.sh "apt remove -y $(cat $runtime_files_dir/apt-packages | tr '\n' ' ')"
fi

#----------------------------------------------------------------------
# remove snap if any
#----------------------------------------------------------------------

if [ -f $runtime_files_dir/snap-packages ]; then
		while read snap_package_name; do
			commands-for-clients-to-run.sh "echo removing ${snap_package_name}..."
			commands-for-clients-to-run.sh "snap remove $snap_package_name"
		done<$runtime_files_dir/snap-packages
fi

commander.sh
