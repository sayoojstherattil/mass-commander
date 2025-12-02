#!/bin/bash



echo -ne "enter names of packages one by one: "

while read package_name; do
	echo "$package_name" >> /root/mass-commander/runtime-files/packages-to-remove
done

echo 'apt remove $(cat /root/mass-commander/files-from-server/packages-to-remove) -y' > /root/mass-commander/runtime-files/commands-to-run
echo "apt autoremove -y" >> /root/mass-commander/runtime-files/commands-to-run

echo '/root/mass-commander/runtime-files/packages-to-remove' >> files-to-tar

/root/mass-commander/scripts/commander.sh
