#!/bin/bash

#----------------------------------------------------------------
# variables
#----------------------------------------------------------------
export netcat_file_loc="$working_dir/netcat_file.sh"


prompt() {
	message="$1"

	echo -n "$message"
	read tmp
}

ssh_keys_generator() {
	prompt 'you are going to enter password for accessing all the client machines. never forget that'
	ssh-keygen -t ed25519 -f /root/.ssh/key_for_accessing_client_machines

	prompt 'generating keys for client machines to access the sftp server'
	ssh-keygen -t ed25519 -f /root/.ssh/key_for_accessing_sftp_server -N ""
}

sftp_setup() {
#----------------------------------------------------------------
# install openssh server package if not exists
#----------------------------------------------------------------
	apt list -i | grep openssh-server
	apt update; apt install openssh-server -y

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
	echo 'enter ip of server machine'
	read server_ip

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

ssh_keys_generator
sftp_setup
netcat_file_ensurer
netcat_starter
