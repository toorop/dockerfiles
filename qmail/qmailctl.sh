#!/bin/sh

# description: the qmail MTA

PATH=/var/qmail/bin:/bin:/usr/bin:/usr/local/bin:/usr/local/sbin
export PATH

QMAILDUID=`id -u qmaild`
NOFILESGID=`id -g qmaild`

case "$1" in
  start)
    echo "Starting qmail"
    if svok /etc/service/qmail-send ; then
      svc -u /etc/service/qmail-send /etc/service/qmail-send/log
    else
      echo "qmail-send supervise not running"
    fi
    if svok /etc/service/qmail-smtpd ; then
      svc -u /etc/service/qmail-smtpd /etc/service/qmail-smtpd/log
    else
      echo "qmail-smtpd supervise not running"
    fi
    if [ -d /var/lock/subsys ]; then
      touch /var/lock/subsys/qmail
    fi
    ;;
  stop)
    echo "Stopping qmail..."
    echo "  qmail-smtpd"
    svc -d /etc/service/qmail-smtpd /etc/service/qmail-smtpd/log
    echo "  qmail-send"
    svc -d /etc/service/qmail-send /etc/service/qmail-send/log
    if [ -f /var/lock/subsys/qmail ]; then
      rm /var/lock/subsys/qmail
    fi
    ;;
  stat)
    svstat /etc/service/qmail-send
    svstat /etc/service/qmail-send/log
    svstat /etc/service/qmail-smtpd
    svstat /etc/service/qmail-smtpd/log
    qmail-qstat
    ;;
  doqueue|alrm|flush)
    echo "Flushing timeout table and sending ALRM signal to qmail-send."
    /var/qmail/bin/qmail-tcpok
    svc -a /etc/service/qmail-send
    ;;
  queue)
    qmail-qstat
    qmail-qread
    ;;
  reload|hup)
    echo "Sending HUP signal to qmail-send."
    svc -h /etc/service/qmail-send
    ;;
  pause)
    echo "Pausing qmail-send"
    svc -p /etc/service/qmail-send
    echo "Pausing qmail-smtpd"
    svc -p /etc/service/qmail-smtpd
    ;;
  cont)
    echo "Continuing qmail-send"
    svc -c /etc/service/qmail-send
    echo "Continuing qmail-smtpd"
    svc -c /etc/service/qmail-smtpd
    ;;
  restart)
    echo "Restarting qmail:"
    echo "* Stopping qmail-smtpd."
    svc -d /etc/service/qmail-smtpd /etc/service/qmail-smtpd/log
    echo "* Sending qmail-send SIGTERM and restarting."
    svc -t /etc/service/qmail-send /etc/service/qmail-send/log
    echo "* Restarting qmail-smtpd."
    svc -u /etc/service/qmail-smtpd /etc/service/qmail-smtpd/log
    ;;
  cdb)
    tcprules /etc/tcp.smtp.cdb /etc/tcp.smtp.tmp < /etc/tcp.smtp
    chmod 644 /etc/tcp.smtp.cdb
    echo "Reloaded /etc/tcp.smtp."
    ;;
  help)
    cat <<HELP
   stop -- stops mail service (smtp connections refused, nothing goes out)
  start -- starts mail service (smtp connection accepted, mail can go out)
  pause -- temporarily stops mail service (connections accepted, nothing leaves)
   cont -- continues paused mail service
   stat -- displays status of mail service
    cdb -- rebuild the tcpserver cdb file for smtp
restart -- stops and restarts smtp, sends qmail-send a TERM & restarts it
doqueue -- schedules queued messages for immediate delivery
 reload -- sends qmail-send HUP, rereading locals and virtualdomains
  queue -- shows status of queue
   alrm -- same as doqueue
  flush -- same as doqueue
    hup -- same as reload
HELP
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|doqueue|flush|reload|stat|pause|cont|cdb|queue|help}"
    exit 1
    ;;
esac

exit 0