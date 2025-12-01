#!/bin/bash

set -e

#current_files_in_archive_fetcher
ls /var/cache/apt/archives > /$USER/mass-commander/runtime-files/files-in-archive-old

echo -ne "enter names of packages one by one: "

while read package_name; do
	echo "$package_name" >> /$USER/mass-commander/runtime-files/packages-to-install
done

apt-get install --download-only $(cat /$USER/mass-commander/runtime-files/packages-to-install) -y

#current files_in_archive_fetcher
ls /var/cache/apt/archives > /$USER/mass-commander/runtime-files/files-in-archive-new

#new_files_in_archive_identifier
cat /$USER/mass-commander/runtime-files/files-in-archive-new | grep -v -f /$USER/mass-commander/runtime-files/files-in-archive-old > /$USER/mass-commander/runtime-files/fetched-deb-files

mkdir /root/mass-commander/runtime-files/local-repo-creation
cd /root/mass-commander/runtime-files/
cp $(cat fetched-deb-files) /root/mass-commander/runtime-files/local-repo-creation

cd /root/mass-commander/runtime-files/local-repo-creation
dpkg-scanpackages . /dev/null | gzip -9c | tee Packages.gz > /dev/null

echo '/root/mass-commander/permanent-files/temp-sources-file' >> /root/mass-commander/runtime-files/files-to-tar
echo '/root/mass-commander/runtime-files/packages-to-install' >> /root/mass-commander/runtime-files/files-to-tar

echo 'mv /etc/apt/sources.list /etc/apt/sources.list.bak' >> /root/mass-commander/runtime-files/commands-to-run
echo 'apt-get update' >> /root/mass-commander/runtime-files/commands-to-run
echo 'apt-get install $(cat /root/mass-commander/files-from-server/packages-to-install)' >> /root/mass-commander/runtime-files/commands-to-run
echo 'mv /etc/apt/sources.list.bak /etc/apt/sources.list' >> /root/mass-commander/runtime-files/commands-to-run

/root/mass-commander/scripts/commander.sh
