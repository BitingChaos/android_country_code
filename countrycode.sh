#!/system/bin/sh
#
# 20160901
#
# Nicholas Caito
# http://xenomorph.net/
#
# this is used to change the SIM card locale.
# it can help with Hangouts adding the wrong country prefix.
#
# this is designed to run on startup, using sysinit / init.d
#
# us = +1
# gb = +44
#
# setting it in /system/build.prop is over written during SIM init after boot
#
# i found this script when looking for ways of doing this:
# https://gist.github.com/hexchain/f4c8a3583abe0214922a
#

# root check
if [[ $EUID -ne 0 ]]; then
  echo "This script needs root access."
  exit 1
fi

# set some variables:

# what country code do you wish to use?
COUNTRY="us"

# how many minutes should this run before giving up?
MINUTES=5

# --------------------

# where to log
LOG=/data/local/tmp/sim.log

# calculate loops, based on number of minutes with a 5-second pause between attempts
LOOPS=$(expr $MINUTES \* 60 / 5)

# debug / logging:
echo "CURRENT COUNTRY CODE: $(/system/bin/getprop gsm.sim.operator.iso-country)" > $LOG
echo "Desired country code: $COUNTRY" >> $LOG
echo "Minutes to run: $MINUTES" >> $LOG
echo "Loops to run: $LOOPS" >> $LOG

# loop and delay until the SIM is ready
for i in `seq $LOOPS`; do

  # read SIM info
  SIM=$(/system/bin/getprop gsm.sim.state)
  echo "Current SIM status: $SIM" >> $LOG

  if [ "$SIM" == "READY" ]; then
    echo "The SIM is ready. Ending loop." >> $LOG
    break;
  fi
  
  sleep 5

done

# make the actual change
/system/bin/setprop gsm.sim.operator.iso-country $COUNTRY

echo "CURRENT COUNTRY CODE: $(/system/bin/getprop gsm.sim.operator.iso-country)" >> $LOG

# EoF