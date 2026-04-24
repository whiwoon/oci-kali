#!/bin/bash

trap 'service xrdp stop; exit 0' SIGTERM SIGINT

if [ ! -f /home/kali/.xsession ]; then
    echo "export XDG_SESSION_DESKTOP=xfce" > /home/kali/.xsession
    echo "export XDG_CURRENT_DESKTOP=XFCE" >> /home/kali/.xsession
    echo "exec dbus-run-session -- startxfce4" >> /home/kali/.xsession
    chmod +x /home/kali/.xsession
    chown kali:kali /home/kali/.xsession
fi

chown kali:kali /home/kali

eval $(dbus-launch --sh-syntax)

service xrdp start || { echo "ERROR: xrdp failed to start"; exit 1; }

tail -f /dev/null &
wait $!
