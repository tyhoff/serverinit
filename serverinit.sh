#!/bin/sh

apt-get update

apt-get install -y aptitude

aptitude update
aptitude upgrade -y 

echo "America/Indiana/Indianapolis" | tee /etc/timezone

adduser bigmac
adduser bigmac sudo

aptitude install -y python-software-properties
add-apt-repository -y ppa:deluge-team/ppa
aptitude update
aptitude install -y fail2ban deluged deluge-webui build-essential curl nodejs


#################
# SSH
#################

mkdir ~/.ssh
touch ~/.ssh/authorized_keys
cat root.pub >> ~/.ssh/authorized_keys
chmod 644 ~/.ssh/authorized_keys

mkdir /home/bigmac/.ssh
touch /home/bigmac/.ssh/authorized_keys
cat bigmac.pub >> /home/bigmac/.ssh/authorized_keys
chmod 644 /home/bigmac/.ssh/authorized_keys

sed -i 's/Port 22/Port 3248/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin without-password/g' /etc/ssh/sshd_config

service ssh restart

#################
# Deluge
#################

adduser --disabled-password --system --home /var/lib/deluge --gecos "Deluge server" --group deluge
groupadd automate
usermod -a -G automate deluge
usermod -a -G automate bigmac
chgrp -R automate /var/lib/deluge
chmod -R 775 /var/lib/deluge
chgrp -R automate /home/bigmac/deluge
chmod -R 775 /home/bigmac/deluge

cp ~/serverinit/deluge/default /etc/default/deluge-daemon
cp ~/serverinit/deluge/init /etc/init.d/deluge-daemon
chmod 755 /etc/init.d/deluge-daemon
update-rc.d deluge-daemon defaults
invoke-rc.d deluge-daemon start
sleep 2
/etc/init.d/deluge-daemon stop
sleep 2
invoke-rc.d deluge-daemon start
sleep 2
/etc/init.d/deluge-daemon stop
sleep 2

echo "applez:cookie17:10" >> /var/lib/deluge/.config/deluge/auth

/etc/init.d/deluge-daemon start
sleep 3


#################
# HTTP
#################

chgrp -R automate /var/www
chmod -R 775 /var/www


#################
# NeoRouter
#################
cd
dpkg -i serverinit/nrserver
dpkg -i serverinit/nrclient
nrserver -adduser user password admin
nrserver -adduser user2 password2 user

#nrclientcmd -d tyhoffman.com -u bigmac -p bacon






