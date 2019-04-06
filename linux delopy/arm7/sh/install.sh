#!/bin/bash
if [ `whoami` = "root" ];then
	echo "Go"
else
  { mane=$(pwd)
    echo "需使用root用户"
	echo "请执行sudo -i 或者 su"
	echo "然后执行 bash $mane/install.sh"
	echo "注:脚本只可以执行一次"
	exit 0;
	}
fi
sudo apt-get install -y wget ca-certificates    apt-transport-https  curl net-tools  dpkg  unzip gnupg
echo "deb https://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
echo "deb http://linux-packages.resilio.com/resilio-sync/deb resilio-sync non-free" | sudo tee /etc/apt/sources.list.d/resilio-sync.list
wget -qO - https://linux-packages.resilio.com/resilio-sync/key.asc | sudo apt-key add -
wget http://www.webmin.com/jcameron-key.asc&&apt-key add jcameron-key.asc
sudo apt update

sudo apt-get install -y  apache2  php7.0   php-zip php-dompdf php-xml php-mbstring  php-curl php-mysql  php-gd  samba resilio-sync webmin 


#ΦΥΆΛ
#echo "deb https://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
#wget http://www.webmin.com/jcameron-key.asc&&apt-key add jcameron-key.asc
#sudo apt-get update&&sudo apt-get install webmin -y
sudo echo "
[sdcard]
    comment = samba home directory
    path = /mnt/sdcard
    public = yes
    browseable = yes
    writable = yes
[BT]
    comment = samba home directory
    path = /root/Downloads/
    public = yes
    browseable = yes
    writable = yes	
[www]
    comment = samba home directory
    path = /var/www/html/
    public = yes
    browseable = yes
    writable = yes " >>   /etc/samba/smb.conf
	
	useradd -m smb
  echo "请输入密码"	
	sudo smbpasswd -a smb

sudo apt-get install qbittorrent-nox aria2 -y
sudo mkdir /etc/aria2
install=$(pwd)
wget https://github.com/ainiyt/a/raw/master/linux%20delopy/arm7/zip/install.zip
wget https://downloads.plex.tv/plex-media-server-new/1.15.3.876-ad6e39743/debian/plexmediaserver_1.15.3.876-ad6e39743_armhf.deb
sudo chmod -R 755 $install/install.zip
sudo unzip $install/install.zip
sudo chmod -R 777 $install/install/
sudo mv $install/install/BaiduPCS-Go /usr/bin/
sudo mv $install/install/html/* /var/www/html/
sudo chmod -R 777 /var/www/
sed -i '32s\ \<p><a href="#" onclick="javascript:window.location.port=10000">终端</p>\'  /var/www/html/index.html
sudo mv $install/install/config/sync.conf /opt/
sudo mv $install/install/config/aria2/*  /etc/aria2/
sudo mv $install/install/init.d/* /etc/init.d/
sudo update-rc.d duo defaults 99
sed -i  '6s\#\AddType application/x-httpd-php .php\' /etc/apache2/apache2.conf
sudo dpkg -i $install/plexmediaserver_1.15.3.876-ad6e39743_armhf.deb
if [ ! -f "/etc/rc.local" ];then
sudo cp /lib/systemd/system/rc-local.service /etc/systemd/system/rc-local.service
sudo echo "
[Install]
WantedBy=multi-user.target " >>  /etc/systemd/system/rc-local.service
sudo echo "
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
qbittorrent-nox >/dev/null&
sudo aria2c --conf-path=/etc/aria2/aria2.conf -D&
BaiduPCS-Go  >/dev/null&
sudo  netdata >/dev/null&
/usr/bin/rslsync  --config /opt/sync.conf >/dev/null&
service apache2 restart&
service smbd restart >/dev/null&

exit 0 " >>  /etc/rc.local
sudo chown root:root /etc/rc.local
sudo chmod 755 /etc/rc.local
sudo systemctl enable rc-local.service
else

echo "----------------------"

fi
bash <(curl -Ss https://my-netdata.io/kickstart.sh)

	
