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
grep "https://download.webmin.com/download/repository" /etc/apt/sources.list >/dev/null
if [ $? -eq 0 ]; then
    echo "已有webmin源"
else
	echo "deb https://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
    echo "webmin添加done"
fi
grep "http://linux-packages.resilio.com/resilio-sync/deb" /etc/apt/sources.list.d/resilio-sync.list >/dev/null
if [ $? -eq 0 ]; then
    echo "已有sync源"
else
	echo "deb http://linux-packages.resilio.com/resilio-sync/deb resilio-sync non-free" | sudo tee /etc/apt/sources.list.d/resilio-sync.list
    echo "sync源添加done"
fi
wget -qO - https://linux-packages.resilio.com/resilio-sync/key.asc | sudo apt-key add -
wget http://www.webmin.com/jcameron-key.asc&&apt-key add jcameron-key.asc
sudo apt update

sudo apt-get install -y  apache2  php7.0   php-zip php-dompdf php-xml php-mbstring  php-curl php-mysql  php-gd  samba resilio-sync webmin 


#ΦΥΆΛ
#echo "deb https://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
#wget http://www.webmin.com/jcameron-key.asc&&apt-key add jcameron-key.asc
#sudo apt-get update&&sudo apt-get install webmin -y
grep "sdcard" /etc/samba/smb.conf >/dev/null
if [ $? -eq 0 ]; then
    echo "exist"
else
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
        echo "添加smb配置"
fi

	
	useradd -m smb
  echo "请添加密码"	
	sudo smbpasswd -a smb

sudo apt-get install qbittorrent-nox aria2 -y
sudo mkdir /etc/aria2
install=$(pwd)
if [[ ! -f "$install/install.zip" ]]; then
    echo "下载压缩文件"
    wget https://github.com/ainiyt/a/raw/master/linux%20delopy/arm7/zip/install.zip
	
else
	echo "文件已存在，跳过。"
fi
if [[ ! -f "$install/plexmediaserver_1.15.3.876-ad6e39743_armhf.deb" ]]; then
    echo "下载plex文件"
    wget https://downloads.plex.tv/plex-media-server-new/1.15.3.876-ad6e39743/debian/plexmediaserver_1.15.3.876-ad6e39743_armhf.deb
	
else
	echo "文件plex已存在，跳过。"
fi
sudo chmod -R 755 $install/install.zip
sudo unzip $install/install.zip
sudo chmod -R 777 $install/install/
sudo mv $install/install/BaiduPCS-Go /usr/bin/

sudo mv $install/install/html/* /var/www/html/
sudo chmod -R 777 /var/www/

sudo mv $install/install/config/sync.conf /opt/
sudo mv $install/install/config/aria2/*  /etc/aria2/
sudo mv $install/install/init.d/* /etc/init.d/
sudo update-rc.d duo defaults 99

grep "application/x-httpd-php" /etc/apache2/apache2.conf >/dev/null
if [ $? -eq 0 ]; then
    echo "exist"
else
	echo "apache2添加php配置"
	sed -i  '6s\#\AddType application/x-httpd-php .php\' /etc/apache2/apache2.conf
    
fi

sudo dpkg -i $install/plexmediaserver_1.15.3.876-ad6e39743_armhf.deb
 usermod -a -G aid_inet,aid_net_raw plex
 if [ ! -f "/etc/init.d/plexmediaserver" ];then
  sudo echo "
#!/bin/sh
### BEGIN INIT INFO
# Provides:          plexmediaserver
# Required-Start:    $remote_fs $syslog $networking
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Plex Media Server
# Description:       Plex Media Server for Linux,
#                    More information at http://www.plexapp.com
#                    Many thanks to the great PlexApp team for their wonderfull job !
# Author:            Cedric Quillevere / origin@killy.net
# Rewamped	     Christian Svedin / christian.svedin@gmail.com
# Version:           1.2
### END INIT INFO

# Read configuration variable file if it is present
[ -r /etc/default/plexmediaserver ] && . /etc/default/plexmediaserver

plex_running=`ps ax | grep "\./Plex Media Server" | awk '{ print $1 }' | wc -l`

case "$1" in
    start)
	if [ "$plex_running" -gt 1 ]; then
		echo "Plex already running..."
		exit 0
	fi
	echo -n "Starting Plex Media Server: "
	su -l $PLEX_MEDIA_SERVER_USER -c "/usr/sbin/start_pms &" >/dev/null 2>&1
	sleep 1
	echo "done"
	;;
    stop)
	if [ "$plex_running" -eq 1 ]; then
		echo "Plex Media Server is not running (no process found)..."
		exit 0
	fi
	echo -n "Killing Plex Media Server: "
	# Trying to kill the Plex Media Server itself but also the Plug-ins
	ps ax | grep "Plex Media Server" | awk '{ print $1 }' | xargs kill -15 >/dev/null 2>&1
	ps ax | grep "Plex Plug-in" | awk '{ print $1 }' | xargs kill -15 >/dev/null 2>&1
	ps ax | grep "Plex DLNA Server" | awk '{ print $1 }' | xargs kill -15 >/dev/null 2>&1
	ps ax | grep "Plex Tuner Service" | awk '{ print $1 }' | xargs kill -15 >/dev/null 2>&1
	ps ax | grep "Plex Media Scanner" | awk '{ print $1 }' | xargs kill -15 >/dev/null 2>&1
	ps ax | grep "Plex DLNA Server" | awk '{ print $1 }' | xargs kill -15 >/dev/null 2>&1
	ps ax | grep "Plex Relay" | awk '{ print $1 }' | xargs kill -15 >/dev/null 2>&1
	ps ax | grep "Plex Transcoder" | awk '{ print $1 }' | xargs kill -15 >/dev/null 2>&1
	ps ax | grep "Plex Script Host" | awk '{ print $1 }' | xargs kill -15 >/dev/null 2>&1
	sleep 1
	echo "done"
	;;
    restart)
	sh $0 stop
	sh $0 start
	;;
    status)
        if [ "$plex_running" -gt 1 ]; then
                echo "Plex Media Server process running."
	else
		echo "It seems that Plex Media Server isn't running (no process found)."
        fi
	;;
    *)
	echo "Usage: $0 {start|stop|restart|status}"
	exit 1
	;;
esac

exit 0 " >>  /etc/init.d/plexmediaserver
chmod 755 /etc/init.d/plexmediaserver
sudo update-rc.d plexmediaserver defaults 99
else
  echo "plex脚本已存在"
fi
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
service webmin start
service plexmediaserver start
exit 0 " >>  /etc/rc.local
sudo chown root:root /etc/rc.local
sudo chmod 755 /etc/rc.local
sudo systemctl enable rc-local.service
else

echo "----------------------"

fi
echo "开始安装性能监测"
bash <(curl -Ss https://my-netdata.io/kickstart.sh)

	
