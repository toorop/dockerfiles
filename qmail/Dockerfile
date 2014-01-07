# qmail
#
# VERSION               0.0.1

FROM ubuntu:12.04
MAINTAINER Stephane Depierrepont <toorop@toorop.fr>

# make sure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update

RUN apt-get install -y apt-get install ucspi-tcp daemontools daemontools-run

# Get qmail src
RUN cd /usr/local/src/
RUN wget http://www.qmail.org/netqmail-1.06.tar.gz
RUN gunzip netqmail-1.06.tar.gz
RUN tar xpf netqmail-1.06.tar

# Add qmail dir
RUN mkdir -p /var/qmail

# Add user
groupadd nofiles
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

