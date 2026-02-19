export server_public_key="<replace_with_server_public_key>"

checker() {
	if [ $? != 0 ]; then
		exit 1	
	fi
}

save_display_number() {
	(echo $DISPLAY | sudo tee /root/display_number) >/dev/null
	checker
}

root_ssh_setup() {
	sudo apt update
	sudo apt install openssh-server -y

	grep -e '^PermitRootLogin prohibit-password' /etc/ssh/sshd_config

	if [ $? -ne 0 ]; then
		echo 'PermitRootLogin prohibit-password' | sudo tee -a /etc/ssh/sshd_config
		checker
	fi

	sudo mkdir /root/.ssh -p
	echo "$server_public_key" | sudo tee -a /root/.ssh/authorized_keys
}

save_display_number
root_ssh_setup

echo 'please wait for the server to do the further configurations...'
echo
echo 'after configuration, the system will reboot'
