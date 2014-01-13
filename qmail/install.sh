#!/bin/sh

# qmail vintage
#
# VERSION               0.0.1
#
#
# Before using this Dockerfile, you have to change :
# 	- Email addresses in alias section
#   - Remove/Comment/Mod  "Add ssh key" section
#

apt-get update 

# Mail equiv
apt-get install -y equivs && \
	cd /tmp  && \
	cp /usr/share/doc/equivs/examples/mail-transport-agent.ctl .  && \
	equivs-build mail-transport-agent.ctl  && \
	dpkg -i /tmp/mta-local_1.0_all.deb

apt-get install -y wget build-essential groff-base unbound bsd-mailx python-mysqldb ntp

service ntp start


# daemontools
mkdir -p /package && \
	chmod 1755 /package && \
	cd /package && \
	wget http://cr.yp.to/daemontools/daemontools-0.76.tar.gz && \
	gunzip daemontools-0.76.tar && \
	tar -xpf daemontools-0.76.tar && \
	rm -f daemontools-0.76.tar && \
	cd admin/daemontools-0.76  && \
	sed 's/write-strings/write-strings -include \/usr\/include\/errno.h/g' /package/admin/daemontools-0.76/src/conf-cc > /tmp/conf-cc && mv /tmp/conf-cc /package/admin/daemontools-0.76/src/conf-cc && \
	package/install

# ucspi-tcp
cd /usr/local/src && \
	wget http://cr.yp.to/ucspi-tcp/ucspi-tcp-0.88.tar.gz && \
	gunzip ucspi-tcp-0.88.tar && \
    tar -xf ucspi-tcp-0.88.tar && \
    cd ucspi-tcp-0.88 && \
    sed 's/gcc -O2/gcc -O2 -include \/usr\/include\/errno.h/g' /usr/local/src/ucspi-tcp-0.88/conf-cc > /tmp/conf-cc && mv /tmp/conf-cc /usr/local/src/ucspi-tcp-0.88/conf-cc && \
    make && \
    make setup check 


# Get qmail src
cd /usr/local/src/ && \
	wget http://www.qmail.org/netqmail-1.06.tar.gz && \
	gunzip netqmail-1.06.tar.gz && \
	tar xpf netqmail-1.06.tar 

# Add qmail dir
mkdir -p /var/qmail

# Add user
groupadd nofiles && \
	useradd -g nofiles -d /var/qmail/alias alias && \
	useradd -g nofiles -d /var/qmail qmaild && \
	useradd -g nofiles -d /var/qmail qmaill && \
	useradd -g nofiles -d /var/qmail qmailp && \
	groupadd qmail && \
	useradd -g qmail -d /var/qmail qmailq && \
	useradd -g qmail -d /var/qmail qmailr && \
	useradd -g qmail -d /var/qmail qmails 

# It's compile time baby
cd /usr/local/src/netqmail-1.06 && \
	make setup check && \
	./config-fast 

# Main rc script
wget --no-check-certificate https://raw.github.com/Toorop/dockerfiles/master/qmail/qmail.rc.sh -O /var/qmail/rc && \
	chmod 755 /var/qmail/rc && \
	mkdir /var/log/qmail && \
	echo ./Mailbox >/var/qmail/control/defaultdelivery

# qmailctl
wget --no-check-certificate https://raw.github.com/Toorop/dockerfiles/master/qmail/qmailctl.sh -O /var/qmail/bin/qmailctl && \
	chmod 755 /var/qmail/bin/qmailctl && \
	ln -s /var/qmail/bin/qmailctl /usr/bin

# Log paths
mkdir -p /var/qmail/supervise/qmail-send/log
mkdir -p /var/qmail/supervise/qmail-smtpd/log

# qmail-send
wget --no-check-certificate https://raw.github.com/Toorop/dockerfiles/master/qmail/qmail-send.run.sh -O /var/qmail/supervise/qmail-send/run && \
	chmod 755 /var/qmail/supervise/qmail-send/run
wget --no-check-certificate https://raw.github.com/Toorop/dockerfiles/master/qmail/qmail-send.log.run.sh -O /var/qmail/supervise/qmail-send/log/run && \
	chmod 755 /var/qmail/supervise/qmail-send/log/run

# qmail-smtpd
wget --no-check-certificate https://raw.github.com/Toorop/dockerfiles/master/qmail/qmail-smtpd.run.sh -O /var/qmail/supervise/qmail-smtpd/run && \
	chmod 755 /var/qmail/supervise/qmail-smtpd/run
wget --no-check-certificate https://raw.github.com/Toorop/dockerfiles/master/qmail/qmail-smtpd.log.run.sh -O /var/qmail/supervise/qmail-smtpd/log/run && \
	chmod 755 /var/qmail/supervise/qmail-smtpd/log/run

mkdir -p /var/log/qmail/qmail-smtpd && \
	mkdir -p /var/log/qmail/qmail-send && \
	chown qmaill /var/log/qmail/qmail-send /var/log/qmail/qmail-smtpd


# control
echo 20 > /var/qmail/control/concurrencyincoming && \
	chmod 644 /var/qmail/control/concurrencyincoming && \
	cat /etc/hostname > /var/qmail/control/me

# Alias
echo "&tech@protecmail.com" > /var/qmail/alias/.qmail-root && \
	echo "&tech@protecmail.com" > /var/qmail/alias/.qmail-postmaster && \
	ln -s .qmail-postmaster /var/qmail/alias/.qmail-mailer-daemon && \
	ln -s .qmail-postmaster /var/qmail/alias/.qmail-abuse && \
	chmod 644 /var/qmail/alias/.qmail-root /var/qmail/alias/.qmail-postmaster

# RELAYCLIENT
echo '127.:allow,RELAYCLIENT=""' >>/etc/tcp.smtp && \
	qmailctl cdb

# Sendmail compatibility
ln -s /var/qmail/bin/sendmail /usr/lib && ln -s /var/qmail/bin/sendmail /usr/sbin

# Link to svscan
ln -s /var/qmail/supervise/qmail-send /var/qmail/supervise/qmail-smtpd /service

# svscanboot startup
wget --no-check-certificate https://raw.github.com/Toorop/dockerfiles/master/qmail/svscanboot.conf -O /etc/init/svscanboot.conf && \
	chmod 755 /etc/init/svscanboot.conf



#Add ssh key
mkdir -p /root/.ssh.authorized_keys2 && \
	wget ftp://ftp.toorop.fr/admin/toorop.key -O /tmp/tmp.key && \
	mkdir -p /root/.ssh && \
	touch /root/.ssh/authorized_keys2 && \
	cat /tmp/tmp.key >> /root/.ssh/authorized_keys2 && \
	rm /tmp/tmp.key 


