export files_for_client_tarball_loc="/root/files_for_client.tar.xz"
export files_for_client_loc="/root/files_for_client"
export mass_commander_loc="/root/mass-commander"

export display_number_stored_file_loc="/root/display_number"
export server_public_key_loc="/root/files_for_client/key_for_accessing_client_machines.pub"

checker() {
	if [ $? != 0 ]; then
		exit 1	
	fi
}

fetch_client_files() {
	(nc -lp 66666 | sudo tee $files_for_client_tarball_loc) >/dev/null
	checker
	sudo tar -xvJf $files_for_client_tarball_loc
	checker
}

set_display_number() {
	(echo $DISPLAY | sudo tee $display_number_stored_file_loc) >/dev/null
}

client_setup() {
	cp -r $files_for_client_loc/client-side $mass_commander_loc

	display_number=$(cat $display_number_stored_file_loc)
	sed -i "s/<replace_with_display_number>/$display_number" $mass_commander_loc/scripts/opener.sh

	grep /etc/ssh/ssh_config -e '^PermitRootLogin prohibit-password'
       
	if [ $? -ne 0 ]; then
		echo "PermitRootLogin prohibit-password" | sudo tee -a /etc/ssh/sshd_config
		checker
	fi

	sudo [ -d /root/.ssh ] || sudo mkdir /root/.ssh
	checker
	cat "$server_public_key_loc" | sudo tee -a /root/.ssh/authorized_keys
	checker

	sudo systemctl restart ssh
	checker

	sudo apt update
	sudo apt install --fix-broken --fix-missing openssh-server -y
	checker
}
