#!/bin/bash

#----------------------------------------------------------------
# variables
#----------------------------------------------------------------
export working_dir="/root/clients_setup"
export netcat_file_loc="$working_dir/netcat_file.sh"
export openssh_server_package_name="openssh-server"


prompt() {
	message="$1"

	echo -n "$message"
	read tmp
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

#----------------------------------------------------------------
# write the sftp accessing private key to netcat file
#----------------------------------------------------------------
private_key=$(cat /root/.ssh/key_for_accessing_sftp_server)
sed -i "s|<replace_with_client_public_key>|$private_key|g"
}

server_setup() {
#----------------------------------------------------------------
# install arp-scan
#----------------------------------------------------------------

	apt update; apt install arp-scan -y
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

netcat_file_ensurer() {
	[ -f $netcat_file_loc ] || echo 'couldnt find the file for netcat' ; exit 1
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
}

new_user_creator() {
	sudo useradd -m -s /bin/bash $new_username -G sudo
	echo "$new_username:$new_user_password" | sudo chpasswd
}

ssh_keys_generator
server_setup
sftp_setup
netcat_file_ensurer
netcat_starter

ip_address_fetcher
client_sftp_access_setup
new_user_creator
