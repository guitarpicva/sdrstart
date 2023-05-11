#!/bin/bash
# change the frequency and mode of the airspy-fmradion
# Usage: ~/sdrstart/chgfreqmode.sh <FREQ_HZ> <mode>
# Example ~/sdrstart/chgfreqmode.sh 14070000 usb
sudo killall airspy-fmradion
$HOME/sdrstart/sdrstart.sh $1 $2
exit 0

