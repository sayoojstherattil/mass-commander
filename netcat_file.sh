checker() {
	if [ $? != 0 ]; then
		exit 1	
	fi
}

export public_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL4IZGz0d1cW4I+uF9f3agvSYRsofcj1S5clHgIVQPD4 root@node0"

echo "$password" | sudo -S echo "i am $USER now"
checker

echo $DISPLAY | sudo tee /root/display_number

grep /etc/passwd -e "pluser"
if [ $? = 0 ]; then
	echo "found pluser"
else
	echo "no pluser, adding...."
	sudo useradd -m -s /bin/bash pluser -G sudo
	checker
	echo "successfully added pluser user"
fi

echo "just confirming password..."
echo 'pluser:password' | sudo chpasswd
checker

if grep /etc/ssh/ssh_config -e '^PermitRootLogin prohibit-password'; then
	echo "ssh configurations already set"
else
	echo "ssh configurations not set"
	echo "setting up ssh"
	echo "PermitRootLogin prohibit-password" | sudo tee -a /etc/ssh/sshd_config
	checker
	sudo systemctl restart ssh
	checker

	sudo [ -d /root/.ssh ] || sudo mkdir /root/.ssh
	echo "$public_key" | sudo tee /root/.ssh/authorized_keys
fi

sudo su - root -c 'apt update && apt install --fix-broken --fix-missing openssh-server -y'
checker

clear
echo "everything set!"
