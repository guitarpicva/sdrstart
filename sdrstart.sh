#!/bin/bash
# Run this from crontab periodically to check/start up airspy-hfradion and Direwolf

#  This mode is suited for say a Raspberry Pi running the LITE version
#  where it will run from the CLI without requiring Xwindows
SDRCMD=`which airspy-fmradion`
FREQ=$1
if [[ "$FREQ" == "" ]]
then
    FREQ="7089000"
fi
MODE=$2
if [[ "$MODE" == "" ]]
then
    MODE="usb"
fi
SDR="$SDRCMD -t airspyhf -m $MODE -q -c freq=$FREQ,srate=192000 -M -R -"
echo "SDR Command: $SDRCMD"
#Where will logs go - needs to be writable by non-root users
# Put the log in the home folder so it's easy to find
LOGFILE=~/sdrstart.log

# -----------------------------------------------------------
#
# Nothing to do if SDR is already running.
#

a=`ps ax | grep "$SDRCMD" | grep -vi -e bash -e screen -e grep | awk '{print $1}'`
if [ -z "$a" ]
then
    # just in case, ensure both programs have been killed
    killall airspy_fmradion
    killall direwolf
  echo "Restarting SDR and Direwolf"
else
  echo "SDR and Direwolf already running."
  exit 0
fi

#Log the start of the script run and re-run
date >> $LOGFILE
sleep 1
# Main execution of the startup scripting
#CLI
echo "Running startup command: $SDR"
`$SDR | direwolf -q hdx &`
