set -e
apt update
apt install snapd -y
set +e
[ -d /root/mass-commander ] || mv /root/client-side /root/mass-commander
set -e
set +e
[ -f /home/opener.sh ] || mv /root/mass-commander/scripts/opener.sh /home
set -e
set +e
[ -f /home/display_number_of_this_machine ] || mv /root/display_number /home/display_number_of_this_machine
set -e


ls /home > /root/home_dir_files
grep -f /root/home_dir_files /etc/shadow | awk -F':' '{print $1}' > /root/actual_normal_users
while read existing_username; do
	set +e
	grep -w '../opener.sh >.opener-output 2>&1 &' /home/$existing_username/.profile || echo '../opener.sh >.opener-output 2>&1 &' >> /home/$existing_username/.profile
	set -e
	chown $existing_username:$existing_username /home/$existing_username/.profile
done</root/actual_normal_users


reboot
