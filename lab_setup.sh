#!/bin/bash


export working_dir="/root/lab_setup"
export mass_commander_dir_loc="$working_dir/mass_commander"
export netcat_file_loc="$mass_commander_dir_loc/netcat_file.sh"

export key_for_accessing_sftp_server_loc="/root/.ssh/key_for_accessing_sftp_server"
export key_for_accessing_client_machines_loc="/root/.ssh/key_for_accessing_client_machines"

export shell_for_new_user="/bin/bash"
export new_user_username="pluser"
export new_user_password="password"
export new_user_profile_loc="/home/$new_user_username/.profile"


prompt() {
	message="$1"

	echo
	echo -n "$message [press enter to continue]"
	read tmp
	echo
}

necessary_files_ensurer() {
	for i in {$netcat_file_loc,$mass_commander_server_dir_loc,$mass_commander_client_dir_loc}; do 
		if ! [ -f $i ]; then
			echo "couldnt find $i"
			exit 1
		fi
	done
}


ssh_keys_generator() {
	prompt 'you are going to enter password for accessing all the client machines. never forget that'
	ssh_keygen -t ed25519 -f $key_for_accessing_client_machines_loc
	server_public_key=$(cat ${key_for_accessing_client_machines_loc}.pub)

	sed -i "s|<replace_with_server_public_key>|$server_public_key|g" $netcat_file_loc

	prompt 'generating keys for client machines to access the sftp server'
	ssh_keygen -t ed25519 -f $key_for_accessing_sftp_server_loc -N ""
}


server_setup() {
	(echo 'export PATH="$PATH:/root/mass_commander/scripts"' | tee -a /root/.profile) >/dev/null
	(echo "alias mass_commander='main_program.sh'" | tee -a /root/.bashrc) >/dev/null

	apt update; apt install arp_scan openssh_server snapd -y

	echo "enter server ip without subnet"
	read server_ip

	echo "enter subnet mask"
	read subnet_mask

	cp -r $mass_commander_dir_loc/server_side /root/mass_commander
	(echo "${server_ip}/${subnet_mask}" | tee /root/mass_commander/permanent_files/permanent_ip_address_with_subnet_mask) >/dev/null

	groupadd sftpgroup
	useradd -G sftpgroup -d /srv/sftpuser -s /sbin/nologin sftpuser

	prompt 'enter the password for your sftp server'
	passwd sftpuser	

	mkdir -p /srv/sftpuser
	chown root /srv/sftpuser
	chmod g+rx /srv/sftpuser

	mkdir -p /srv/sftpuser/data
	chown sftpuser:sftpuser /srv/sftpuser/data

	grep -e '^Subsystem      sftp    /usr/lib/openssh/sftp_server' /etc/ssh/sshd_config 

	if [ $? -eq 0 ]; then
		sed -i /etc/ssh/sshd_config 's|Subsystem      sftp    /usr/lib/openssh/sftp_server|#Subsystem      sftp    /usr/lib/openssh/sftp_server|g'
	fi
	
		(echo "Subsystem sftp internal_sftp" | tee -a /etc/ssh/sshd_config) >/dev/null
		(echo | tee -a /etc/ssh/sshd_config) >/dev/null
		(echo "Match Group sftpgroup" | tee -a /etc/ssh/sshd_config) >/dev/null
		(echo -e "\tChrootDirectory %h" | tee -a /etc/ssh/sshd_config) >/dev/null
		(echo -e "\tX11Forwarding no" | tee -a /etc/ssh/sshd_config) >/dev/null
		(echo -e "\tAllowTCPForwarding no" | tee -a /etc/ssh/sshd_config) >/dev/null
		(echo -e "\tForceCommand internal_sftp" | tee -a /etc/ssh/sshd_config) >/dev/null

	mkdir /srv/sftpuser/.ssh -p
	((cat ${key_for_accessing_sftp_server_loc}.pub | tee /srv/sftpuser/.ssh/authorized_keys) >/dev/null) >/dev/null

	systemctl restart ssh
}

clients_setup() {
	echo "enter port no to use"
	read port_no

	arp_scan ${server_ip}/${subnet_mask} >$working_dir/arp_scan_output

	last_line_number=$(wc -l $working_dir/arp_scan_output | awk -F' ' '{print $1}')
	line_just_below_result=$(($last_line_number - 2))

	cat $working_dir/arp_scan_output | sed "${line_just_below_result},${last_line_number}d" | sed '1,2d' > $working_dir/arp_scan_unwanted_lines_deleted
	cat $working_dir/arp_scan_unwanted_lines_deleted | awk -F' ' '{print $1}' > $working_dir/ip_address_pool 

	prompt "enter the command in all clients (make sure that you enter the command logged in as a user which is in the sudo group): nc -lp $port_no | bash"

	while read client_ip_address; do
		cat $netcat_file_loc | nc -q 1 $client_ip_address $port_no &
	done<$working_dir/ip_address_pool

	prompt 'make sure all clients have completed the task'

	eval $(ssh_agent)
	ssh_add $key_for_accessing_client_machines_loc
	while read client_ip_address; do
		scp -o StrictHostKeyChecking=no  $key_for_accessing_sftp_server_loc $client_ip_address:.ssh
		scp -r $mass_commander_dir_loc/client_side $client_ip_address:
	done<$working_dir/ip_address_pool

	while read client_ip_address; do
		ssh -o StrictHostKeyChecking=no $client_ip_address "apt update; apt install snapd -y; mv /root/client_side /root/mass_commander ; mv /root/mass_commander/scripts/opener.sh /home; (echo '$server_ip/$subnet_mask' | tee /root/mass_commander/permanent_files/permanent_ip_address_with_subnet_mask) >/dev/null; useradd -m -s /bin/bash $new_user_username ; echo '$new_user_username:$new_user_password' | chpasswd ; (cat /root/mass_commander/scripts/profile_last_part | tee -a $new_user_profile_loc) >/dev/null;chown $new_user_username:$new_user_username $new_user_profile_loc;mv /root/display_number /home/display_number_of_this_machine; reboot" &
	done<$working_dir/ip_address_pool
}

necessary_files_ensurer
ssh_keys_generator
server_setup
clients_setup
