checker() {
	if [ $? != 0 ]; then
		exit 1	
	fi
}

sudo_privilege_ensurer() {
	sudo whoami >/dev/null
	echo "successfully became root user"
}

display_number_save() {
	(echo $DISPLAY | sudo tee /root/display_number) >/dev/null
}


server_root_access_setup() {
#----------------------------------------------------------------
# ensure root login parameter is set
#----------------------------------------------------------------
	echo "making root login possible..."

	grep /etc/ssh/ssh_config -e '^PermitRootLogin prohibit-$new_user_password'
       
	if [ $? -ne 0 ]; then
		echo "PermitRootLogin prohibit-password" | sudo tee -a /etc/ssh/sshd_config
		checker
	fi

#----------------------------------------------------------------
# adding pub key for root login
#----------------------------------------------------------------
	sudo [ -d /root/.ssh ] || sudo mkdir /root/.ssh
	echo "$server_public_key" | sudo tee /root/.ssh/authorized_keys

#----------------------------------------------------------------
# restart ssh service
#----------------------------------------------------------------
	sudo systemctl restart ssh
	checker
}

ssh_server_package_installation() {
	sudo su - root -c "apt update && apt install --fix-broken --fix-missing $openssh_server_package_name -y"
	checker
}

sudo_privilege_ensurer
display_number_save
server_root_access_setup
ssh_server_package_installation

echo "more things will be done by the server. you can ensure everything is set by seeing this machine reboot. please wait...."
