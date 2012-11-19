#!/bin/sh
### BEGIN INIT INFO
# Provides:          liquidsoap
# Required-Start:    $remote_fs $network $time
# Required-Stop:     $remote_fs $network $time
# Should-Start:
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts the liquidsoap daemon
# Description:
### END INIT INFO

user=liquidsoap
group=liquidsoap
prefix=/usr
exec_prefix=${prefix}
confdir=/etc/liquidsoap
liquidsoap=${exec_prefix}/bin/liquidsoap
rundir=/var/run/liquidsoap

# Test if $rundir exists
if [ ! -d $rundir ]; then
  mkdir -p $rundir;
  chown $user:$group $rundir
fi

case "$1" in
  stop)
    echo -n "Stopping liquidsoap channels: "
    cd $rundir
    has_channels=
    for liq in *.pid ; do
      if test $liq != '*.pid' ; then
        has_channels=1
        echo -n "$liq "
        start-stop-daemon --stop --quiet --pidfile $liq --retry 4
      fi
    done
    if test -n "$has_channels"; then
      echo "OK"
    else
      echo "no script found in $confdir"
    fi
    ;;

  start)
    echo -n "Starting liquidsoap channels: "
    cd $confdir
    has_channels=
    for liq in *.liq ; do
      if test $liq != '*.liq' ; then
        has_channels=1
        echo -n "$liq "
        start-stop-daemon --start --quiet --pidfile $rundir/${liq%.liq}.pid \
          --chuid $user:$group --exec $liquidsoap -- -d $confdir/$liq
      fi
    done
    if test -n "$has_channels"; then
      echo "OK"
    else
      echo "no script found in $confdir"
    fi
    ;;

  restart|force-reload)
    $0 stop
    $0 start
    ;;

  *)
    echo "Usage: $0 {start|stop|restart|force-reload}"
    exit 1
    ;;
esac
