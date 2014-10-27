#!/bin/sh

mkdir -p /data

if [ ! -f /data/ngircd.conf ]; then 
  if [ "${NGIRCD_CONF_URL}-irc" != "-irc" ]; then 
    curl -o /data/ngircd.conf -s $NGIRCD_CONF_URL
  else 
    echo "ERROR: You have neither supplied a URL nor bind mounted config"
    echo "ERROR: Falling back to default config"

    cp /etc/ngircd.conf /data/

  fi
else 
  echo "Preferring to use existing /data/ngircd.conf"
fi

DOTS=$(echo $HOSTNAME | sed -r 's/[[:alnum:]]*//g' | wc -c)

if [ $DOTS -gt 1 ]; then
  IRCNAME="$(hostname -f)"
else
  IRCNAME="$(hostname -f).local"
  echo "ERROR: Your hostname does not follow ngircd's required pattern"
  echo "ERROR: Changing hostname to $IRCNAME"
fi

sed -r -i "s/^([[:space:]]*)Name[[:space:]]*=[[:space:]]*.+/\1Name = $IRCNAME/g" /data/ngircd.conf

/usr/sbin/ngircd -f /data/ngircd.conf -n 

# vim: set ts=2 sw=2 expandtab:
