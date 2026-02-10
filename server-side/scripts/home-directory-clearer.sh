#!/bin/bash

#----------------------------------------------------------------------
# save folders in home directory
#----------------------------------------------------------------------

ls /home | tee -a $runtime_files_dir_of_client/home-dir-folders

#----------------------------------------------------------------------
# compare and use the common with the /etc/shadow to get actual users
#----------------------------------------------------------------------

grep -f $runtime_files_dir_of_client/home-dir-folders /etc/shadow | awk -F':' '{print $1}' > $runtime_files_dir_of_client/actual-normal-users

#----------------------------------------------------------------------
# clear home dir of each users leaving folders specified in the file
#----------------------------------------------------------------------

#----------------------------------------------------------------------
# first clear everything
#----------------------------------------------------------------------

while read username; do
#----------------------------------------------------------------------
# list contents of that user
#----------------------------------------------------------------------

	ls -a /home/$username > $runtime_files_dir_of_client/contents-of-${username}

#----------------------------------------------------------------------
# remove all files
#----------------------------------------------------------------------

	rm -rf "$(cat $runtime_files_dir_of_client/contents-of-${username} | tr '\n' ' ')"

#----------------------------------------------------------------------
# then create the dirs told in that file
#----------------------------------------------------------------------
	while read folder_name; do
		mkdir /home/$username/$folder_name
	done<$permanent_files_dir/default-folders
done<$runtime_files_dir_of_client/actual-normal-users
