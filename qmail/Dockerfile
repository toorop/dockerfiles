# qmail
#
# VERSION               0.0.1

FROM ubuntu:12.04
MAINTAINER Stephane Depierrepont <toorop@toorop.fr>

# make sure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update

RUN apt-get install -y ucspi-tcp wget build-essentials

# daemontools
RUN mkdir -p /package
RUN chmod 1755 /package
RUN cd /package
RUN wget http://cr.yp.to/daemontools/daemontools-0.76.tar.gz
RUN gunzip daemontools-0.76.tar
RUN tar -xpf daemontools-0.76.tar
RUN rm -f daemontools-0.76.tar
RUN cd admin/daemontools-0.76
RUN package/install



# Get qmail src
RUN cd /usr/local/src/
RUN wget http://www.qmail.org/netqmail-1.06.tar.gz
RUN gunzip netqmail-1.06.tar.gz
RUN tar xpf netqmail-1.06.tar

# Add qmail dir
RUN mkdir -p /var/qmail

# Add user
RUN groupadd nofiles
RUN useradd -g nofiles -d /var/qmail/alias alias
RUN useradd -g nofiles -d /var/qmail qmaild
RUN useradd -g nofiles -d /var/qmail qmaill
RUN useradd -g nofiles -d /var/qmail qmailp
RUN groupadd qmail
RUN useradd -g qmail -d /var/qmail qmailq
RUN useradd -g qmail -d /var/qmail qmailr
RUN useradd -g qmail -d /var/qmail qmails

# It's compile time
RUN cd /usr/local/src/netqmail-1.06
RUN make setup check
RUN ./config

# Main rc script
RUN wget https://raw.github.com/Toorop/dockerfiles/master/qmail/qmail.rc.sh -O /var/qmail/rc 
RUN chmod 755 /var/qmail/rc;
RUN mkdir /var/log/qmail;
RUN echo ./Mailbox >/var/qmail/control/defaultdelivery;

# qmailctl
RUN wget https://raw.github.com/Toorop/dockerfiles/master/qmail/qmailctl.sh -O /var/qmail/bin/qmailctl
RUN chmod 755 /var/qmail/bin/qmailctl
RUN ln -s /var/qmail/bin/qmailctl /usr/bin

# Log paths
RUN mkdir -p /var/qmail/supervise/qmail-send/log
RUN mkdir -p /var/qmail/supervise/qmail-smtpd/log

# qmail-send
RUN wget https://raw.github.com/Toorop/dockerfiles/master/qmail/qmail-send.run.sh -O /var/qmail/supervise/qmail-send/run
RUN wget https://raw.github.com/Toorop/dockerfiles/master/qmail/qmail-send.log.run.sh -O /var/qmail/supervise/qmail-send/log/run
RUN chmod 755 /var/qmail/supervise/qmail-send/run
RUN chmod 755 /var/qmail/supervise/qmail-send/log/run

# qmail-smtpd
RUN wget https://raw.github.com/Toorop/dockerfiles/master/qmail/qmail-smtpd.run.sh -O /var/qmail/supervise/qmail-smtpd/run
RUN wget https://raw.github.com/Toorop/dockerfiles/master/qmail/qmail-smtpd.log.run.sh -O /var/qmail/supervise/qmail-smtpd/log/run
RUN chmod 755 /var/qmail/supervise/qmail-smtpd/run
RUN chmod 755 /var/qmail/supervise/qmail-smtpd/log/run

RUN mkdir -p /var/log/qmail/qmail-smtpd
RUN mkdir -p /var/log/qmail/qmail-send
RUN chown qmaill /var/log/qmail/qmail-send /var/log/qmail/qmail-smtpd


# control
RUN echo 20 > /var/qmail/control/concurrencyincoming
RUN chmod 644 /var/qmail/control/concurrencyincoming

# RELAYCLIENT
RUN echo '127.:allow,RELAYCLIENT=""' >>/etc/tcp.smtp
RUN qmailctl cdb

# Sendmail compatibility
RUN ln -s /var/qmail/bin/sendmail /usr/lib
RUN ln -s /var/qmail/bin/sendmail /usr/sbin

# Link to svscan
RUN ln -s /var/qmail/supervise/qmail-send /var/qmail/supervise/qmail-smtpd /etc/service

EXPOSE 25

