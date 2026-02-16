#!/bin/bash

#----------------------------------------------------------------
# variables
#----------------------------------------------------------------
export working_dir="/root/clients_setup"
export netcat_file_loc="$working_dir/netcat_file.sh"
export mass_commander_server_dir_loc="$working_dir/mass-commander/server-side"
export mass_commander_client_dir_loc="$working_dir/mass-commander/client-side"
export openssh_server_package_name="openssh-server"

#----------------------------------------------------------------
# new user details
#----------------------------------------------------------------

shell_for_new_user="/bin/bash"
new_user_username="pluser"
new_user_password="password"


prompt() {
	message="$1"

	echo -n "$message [press enter to continue]"
	read tmp
}

necessary_files_ensurer() {
#----------------------------------------------------------------
# netcat file
#----------------------------------------------------------------
	[ -f $netcat_file_loc ] || echo 'couldnt find the file for netcat' ; exit 1

#----------------------------------------------------------------
# mass commander folder
#----------------------------------------------------------------
	[ -d $mass_commander_server_dir_loc] || echo 'couldnt find mass commander folder' ; exit 1
}

ssh_keys_generator() {
	prompt 'you are going to enter password for accessing all the client machines. never forget that'
	ssh-keygen -t ed25519 -f /root/.ssh/key_for_accessing_client_machines

#----------------------------------------------------------------
# write the public key to netcat file
#----------------------------------------------------------------
public_key=$(cat /root/.ssh/key_for_accessing_client_machines)
sed -i "s|<replace_with_server_public_key>|$public_key|g"

	prompt 'generating keys for client machines to access the sftp server'
	ssh-keygen -t ed25519 -f /root/.ssh/key_for_accessing_sftp_server -N ""
}

server_setup() {
#----------------------------------------------------------------
# install arp-scan
#----------------------------------------------------------------
	apt update; apt install arp-scan -y

#----------------------------------------------------------------
# setup mass-commander folder
#----------------------------------------------------------------
	mkdir /root/mass-commander
	cp -r $mass_commander_server_dir_loc /root/
}

sftp_setup() {
#----------------------------------------------------------------
# install openssh server package if not exists
#----------------------------------------------------------------
	apt list -i | grep $openssh_server_package_name
	apt update; apt install $openssh_server_package_name -y

#----------------------------------------------------------------
# add user and group
#----------------------------------------------------------------
	groupadd sftpgroup
	useradd -G sftpgroup -d /srv/sftpuser -s /sbin/nologin sftpuser

#----------------------------------------------------------------
# password for sftp server
#----------------------------------------------------------------
	prompt 'enter the password for your sftp server'
	passwd sftpuser	

#----------------------------------------------------------------
# sftp server file hierarchy setup
#----------------------------------------------------------------
	mkdir -p /srv/sftpuser
	chown root /srv/sftpuser
	chmod g+rx /srv/sftpuser

	mkdir -p /srv/sftpuser/data
	chown sftpuser:sftpuser /srv/sftpuser/data

#----------------------------------------------------------------
# comment out the subsystem line
#----------------------------------------------------------------
	grep -e '^Subsystem      sftp    /usr/lib/openssh/sftp-server' /etc/ssh/sshd_config && sed -i /etc/ssh/sshd_config 's/Subsystem      sftp    /usr/lib/openssh/sftp-server/#Subsystem      sftp    /usr/lib/openssh/sftp-server/g'
	
#----------------------------------------------------------------
# add necessary lines to ssh config
#----------------------------------------------------------------
	echo -e "Subsystem sftp internal-sftp\n\nMatch Group sftpgroup\n\tChrootDirectory %h\n\tX11Forwarding no\n\tAllowTCPForwarding no\n\tAllowTCPForwarding no"

#----------------------------------------------------------------
# setting up keybased authentication for clients
#----------------------------------------------------------------
	mkdir /srv/sftpuser/.ssh
	(cat /root/.ssh/key_for_accessing_sftp_server | tee /srv/sftpuser/.ssh/authorized_keys) >/dev/null


	systemctl restart ssh
}

netcat_starter() {
#----------------------------------------------------------------
# get required details
#----------------------------------------------------------------
	echo 'enter ip of server machine without subnet mask'
	read server_ip

	echo 'enter subnet mask'
	read subnet_mask

	echo 'enter port to use'
	read port_no

#----------------------------------------------------------------
# tell admin to enter the netcat commands on client machines
#----------------------------------------------------------------
	echo "enter this command on all client machines and respond to sudo password entry when prompted:"
	echo "nc -ulp $port_no | bash"

#----------------------------------------------------------------
# start netcat after admin confirm he/she has entered the command
# in client machines
#----------------------------------------------------------------
	prompt 'after entering the command on client machines, press enter'

	echo -e "\nstarting netcat"
	cat $netcat_file_loc | nc -u -s $server_ip -b 255.255.255.255 $port_no
}

ip_address_fetcher() {
		arp-scan ${server_ip}/${subnet_mask} >$working_dir/arp_scan_output

	last_line_number=$(wc -l $working_dir/arp_scan_output | awk -F' ' '{print $1}')
	line_just_below_result=$(($last_line_number - 2))

	cat $working_dir/arp_scan_output | sed "${line_just_below_result},${last_line_number}d" | sed '1,2d' > $working_dir/arp_scan_unwanted_lines_deleted
	cat $working_dir/arp_scan_unwanted_lines_deleted | awk -F' ' '{print $1}' > $working_dir/ip_address_pool 
}


client_setup() {
	while read client_ip_address; do
#----------------------------------------------------------------
# sftp access setup
#----------------------------------------------------------------
		ssh root@${client_ip_address} "mkdir -p /root/.ssh"
		scp /root/.ssh/key_for_accessing_sftp_server root@${client_ip_address}:/root/.ssh

#----------------------------------------------------------------
# mass commander client side setup
#----------------------------------------------------------------

#----------------------------------------------------------------
# send, place and configure files appropriately
#----------------------------------------------------------------
		ssh root@${client_ip_address} "mkdir /root/mass-commander"
		scp -r $mass_commander_client_dir_loc root@${client_ip_address}:/root/mass-commander

		mv /root/mass-commander/client-side/scripts/opener.sh /home

#----------------------------------------------------------------
# user setup
#----------------------------------------------------------------
		ssh root@${client_ip_address} "useradd -m -s $shell_for_new_user $new_user_username"
		ssh root@${client_ip_address} "echo '$new_user_username:$new_user_password' | chpasswd"

		cat /root/mass-commander/client-side/scripts/profile-last-part | tee -a /home/

	done<$working_dir/ip_address_pool
}

clients_rebooter() {
	while read client_ip_address; do
		ssh root@${client_ip_address} "reboot"
	done<$working_dir/ip_address_pool
}


necessary_files_ensurer
ssh_keys_generator
server_setup
sftp_setup
netcat_starter

#----------------------------------------------------------------
# post netcat
#----------------------------------------------------------------
ip_address_fetcher
client_setup
clients_rebooter
