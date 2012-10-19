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
add-apt-repository ppa:transmissionbt/ppa
aptitude update
aptitude install -y fail2ban deluged deluge-webui build-essential curl nodejs transmission-daemon

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
nrserver -adduser applez cookie admin
nrserver -adduser bigmac bacon user

nrclientcmd -d tyhoffman.com -u bigmac -p bacon

#################
# Transmission
#################

service transmission-daemon stop

mkdir /home/bigmac/transmission
cd /home/bigmac/transmission
mkdir downloads torrents auto
cd ~/serverinit

sudo usermod -a -G debian-transmission bigmac
sudo chgrp -R debian-transmission /home/bigmac/transmission
sudo chmod -R 770 /home/bigmac/transmission

cat settings.json > /etc/transmission-daemon/settings.json

sudo service transmission-daemon start
sudo service transmission-daemon reload











