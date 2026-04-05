set -e
apt update
apt install snapd -y
mv /root/client-side /root/mass-commander 
mv /root/mass-commander/scripts/opener.sh /home
mv /root/display_number /home/display_number_of_this_machine


ls /home > /root/home_dir_files
grep -f /root/home_dir_files /etc/shadow | awk -F':' '{print $1}' > /root/actual_normal_users
while read existing_username; do
	set +e
	grep -w '../opener.sh >.opener-output 2>&1 &' /home/$existing_username/.profile
	set -e
	[ $? -ne 0 ] && echo '../opener.sh >.opener-output 2>&1 &' >> /home/$existing_username/.profile
	chown $existing_username:$existing_username /home/$existing_username/.profile
done</root/actual_normal_users


reboot
