# qmail vintage
#
# VERSION               0.0.1
#
#
# Before using this Dockerfile, you have to change :
# 	- Email addresses in alias section
#   - Remove/Comment/Mod  "Add ssh key" section
#


FROM ubuntu:12.04
MAINTAINER Stephane Depierrepont <toorop@toorop.fr>

# make sure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list

# initctl fix
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

RUN apt-get update

RUN apt-get install -y wget build-essential groff-base unbound openssh-server nano bsd-mailx

# sshd
RUN mkdir -p /var/run/sshd

# daemontools
RUN mkdir -p /package && \
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
RUN cd /usr/local/src && \
	wget http://cr.yp.to/ucspi-tcp/ucspi-tcp-0.88.tar.gz && \
	gunzip ucspi-tcp-0.88.tar && \
    tar -xf ucspi-tcp-0.88.tar && \
    cd ucspi-tcp-0.88 && \
    sed 's/gcc -O2/gcc -O2 -include \/usr\/include\/errno.h/g' /usr/local/src/ucspi-tcp-0.88/conf-cc > /tmp/conf-cc && mv /tmp/conf-cc /usr/local/src/ucspi-tcp-0.88/conf-cc && \
    make && \
    make setup check 


# Get qmail src
RUN cd /usr/local/src/ && \
	wget http://www.qmail.org/netqmail-1.06.tar.gz && \
	gunzip netqmail-1.06.tar.gz && \
	tar xpf netqmail-1.06.tar 

# Add qmail dir
RUN mkdir -p /var/qmail

# Add user
RUN groupadd nofiles && \
	useradd -g nofiles -d /var/qmail/alias alias && \
	useradd -g nofiles -d /var/qmail qmaild && \
	useradd -g nofiles -d /var/qmail qmaill && \
	useradd -g nofiles -d /var/qmail qmailp && \
	groupadd qmail && \
	useradd -g qmail -d /var/qmail qmailq && \
	useradd -g qmail -d /var/qmail qmailr && \
	useradd -g qmail -d /var/qmail qmails 

# It's compile time
RUN cd /usr/local/src/netqmail-1.06 && \
	make setup check && \
	./config-fast 

# Main rc script
RUN wget --no-check-certificate https://raw.github.com/Toorop/dockerfiles/master/qmail/qmail.rc.sh -O /var/qmail/rc && \
	chmod 755 /var/qmail/rc && \
	mkdir /var/log/qmail && \
	echo ./Mailbox >/var/qmail/control/defaultdelivery

# qmailctl
RUN wget --no-check-certificate https://raw.github.com/Toorop/dockerfiles/master/qmail/qmailctl.sh -O /var/qmail/bin/qmailctl && \
	chmod 755 /var/qmail/bin/qmailctl && \
	ln -s /var/qmail/bin/qmailctl /usr/bin

# Log paths
RUN mkdir -p /var/qmail/supervise/qmail-send/log
RUN mkdir -p /var/qmail/supervise/qmail-smtpd/log

# qmail-send
RUN wget --no-check-certificate https://raw.github.com/Toorop/dockerfiles/master/qmail/qmail-send.run.sh -O /var/qmail/supervise/qmail-send/run && \
		chmod 755 /var/qmail/supervise/qmail-send/run
RUN wget --no-check-certificate https://raw.github.com/Toorop/dockerfiles/master/qmail/qmail-send.log.run.sh -O /var/qmail/supervise/qmail-send/log/run && \
	chmod 755 /var/qmail/supervise/qmail-send/log/run

# qmail-smtpd
RUN wget --no-check-certificate https://raw.github.com/Toorop/dockerfiles/master/qmail/qmail-smtpd.run.sh -O /var/qmail/supervise/qmail-smtpd/run && \
	chmod 755 /var/qmail/supervise/qmail-smtpd/run
RUN wget --no-check-certificate https://raw.github.com/Toorop/dockerfiles/master/qmail/qmail-smtpd.log.run.sh -O /var/qmail/supervise/qmail-smtpd/log/run && \
	chmod 755 /var/qmail/supervise/qmail-smtpd/log/run

RUN mkdir -p /var/log/qmail/qmail-smtpd && \
	mkdir -p /var/log/qmail/qmail-send && \
	chown qmaill /var/log/qmail/qmail-send /var/log/qmail/qmail-smtpd


# control
RUN echo 20 > /var/qmail/control/concurrencyincoming && \
	chmod 644 /var/qmail/control/concurrencyincoming && \
	cat /etc/hostname > /var/qmail/control/me

# Alias
RUN echo "&tech@protecmail.com" > /var/qmail/alias/.qmail-root && \
	echo "&tech@protecmail.com" > /var/qmail/alias/.qmail-postmaster && \
	ln -s .qmail-postmaster /var/qmail/alias/.qmail-mailer-daemon && \
	ln -s .qmail-postmaster /var/qmail/alias/.qmail-abuse && \
	chmod 644 /var/qmail/alias/.qmail-root /var/qmail/alias/.qmail-postmaster

# RELAYCLIENT
RUN echo '127.:allow,RELAYCLIENT=""' >>/etc/tcp.smtp && \
	qmailctl cdb

# Sendmail compatibility
RUN ln -s /var/qmail/bin/sendmail /usr/lib
RUN ln -s /var/qmail/bin/sendmail /usr/sbin

# Link to svscan
RUN ln -s /var/qmail/supervise/qmail-send /var/qmail/supervise/qmail-smtpd /service

# Mail equiv
RUN apt-get install equivs && \
	cd /tmp  && \
	cp /usr/share/doc/equivs/examples/mail-transport-agent.ctl .  && \
	equivs-build mail-transport-agent.ctl  && \
	dpkg -i /tmp/mta-local_1.0_all.deb


#Add ssh key
RUN mkdir -p /root/.ssh.authorized_keys2 && \
	wget ftp://ftp.toorop.fr/admin/toorop.key -O /tmp/tmp.key && \
	mkdir -p /root/.ssh && \
	touch /root/.ssh/authorized_keys2 && \
	cat /tmp/tmp.key >> /root/.ssh/authorized_keys2 && \
	rm /tmp/tmp.key 

# SSH server
RUN mkdir -p /var/log/sshd && \
	mkdir -p /service/sshd/log && \
	wget --no-check-certificate https://raw.github.com/Toorop/dockerfiles/master/qmail/ssh.run.sh -O /service/sshd/run && \
	wget --no-check-certificate https://raw.github.com/Toorop/dockerfiles/master/qmail/ssh.log.run.sh -O /service/sshd/log/run && \
	chmod 755 /service/sshd/run && \
	chmod 755 /service/sshd/log/run


# Start
RUN wget https://raw.github.com/Toorop/dockerfiles/master/qmail/start.sh -O /root/start.sh && \
	chmod +x /root/start.sh

EXPOSE 25 22

