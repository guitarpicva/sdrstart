#!/bin/bash
# USAGE: ./RPiOSLiteBuild.sh CALLSIGN [airspy or sdrplay or rtlsdr]

# THIS WILL TAKE A VERY LONG TIME FOR THE COMPILING PARTS 
# FOR HAMLIB AND DIREWOLF.

## Usage Example: ./RPiOSLiteBuild.sh NNX3XA-2 airspy"

echo "Starting RPiOSLiteBuild.sh script...."
echo `date`
## General house-keeping things which are optional
## alias the "ll" command
echo "alias ll='ls -lA --color=auto'" >> $HOME/.bashrc
## and use htop instead of old top
echo "alias top='htop'" >> $HOME/.bashrc
source $HOME/.bashrc
MYCALL=$1
echo "MYCALL: $MYCALL"
    
if [[ "$MYCALL" == "" ]]
then
    echo "Usage : ./RPiOSLiteBuils.sh CALLSIGN [airspy or sdrplay or rtlsdr]"
    echo "NOTE: ONLY airspy is a valid choice at this time!!!!!!!!!!!!!!!!!!!"
    echo "Where CALLSIGN is required, and is the call sign of the station."
    echo ""
    echo "The 'airspy' (case sensitive) second parameter is optional."
    echo "It will install the airspy-fmradion SDR demodulator for use as"
    echo "a receive only station."
    echo ""
    exit 0
fi

## second parameter is optional SDR type name, either sdrplay or airspy or rtlsdr
OPTSDR=$2
if [[ "$OPTSDR" == "" ]]
then
    echo "Disable SDR build..."
else
    echo "Enable SDR build for: $OPTSDR"
fi

# force update and upgrade to latest packages
sudo apt update && sudo apt upgrade -y
# packages required for Hamlib and Direwolf
sudo apt install -y git cmake alsa-base alsa-tools alsa-utils libasound2-dev libtool libudev-dev autotools-dev telnet net-tools qtbase5-dev qtbase5-private-dev mosquitto libusb-1.0-0-dev

# ensure user has permissions to use the devices such as audio and serial ports
sudo adduser "$LOGNAME" dialout
sudo adduser "$LOGNAME" audio
sudo adduser "$LOGNAME" plugdev
sudo adduser "$LOGNAME" crontab

# Compiler flags for compiling Hamlib latest
export CXXFLAGS='-O2 -march=native -mtune=native'
export CFLAGS='-O2 -march=native -mtune=native'

# do normal hamlib (latest) clone and build here
cd ~
mkdir src
cd src
git clone https://github.com/Hamlib/Hamlib.git -b Hamlib-4.5.6
cd Hamlib
# bootstrap to make the configure script
./bootstrap
# this will take a while as this is a very large library
./configure --enable-static && make
sudo make install
sleep 1
sudo ldconfig

# Now Hamlib is in the libraries list and Direwolf can find it 
# for it's cmake
# Do normal direwolf clone and build here
cd ~
mkdir src
cd src
# dev branch has all the cool new stuff
git clone https://github.com/wb2osz/direwolf.git -b dev
cd direwolf
mkdir build
cd build
make clean
cmake ..
make
sudo make install
cp direwolf.conf ~/direwolf.conf.orig

# creates the direwolf.conf with all defaults in home folder
echo "Create direwolf config file for AirSpy HF SDRs"
cd ~
echo "ADEVICE stdin null" > direwolf.conf
echo "ARATE 48000" >> direwolf.conf
echo "ACHANNELS 1" >> direwolf.conf
echo "CHANNEL 0" >> direwolf.conf
echo "MYCALL $MYCALL" >> direwolf.conf
echo "MODEM 700 1100:1900/3" >> direwolf.conf
echo "AGWPORT 0" >> direwolf.conf
echo "KISSPORT 8001" >> direwolf.conf

echo `date`
if [[ "$OPTSDR" == "airspy" || "$OPTSDR" == "rtlsdr" ]]
then    
    echo `date`
    echo "Install packages required for airspy-fmradion...."
    ## optional install airspy-fmradion for AirSpy HF SDR's
    ## many packages are duplicated so this section can be plucked out for use at will
    sudo apt install -y cmake pkg-config libasound2-dev libairspy-dev libairspyhf-dev librtlsdr-dev libsndfile1-dev portaudio19-dev libvolk2-dev libusb-1.0-0-dev
    echo "Clone and compile airspy-fmradion...."
    cd ~
    mkdir src
    cd src
    git clone https://github.com/jj1bdx/airspy-fmradion.git
    cd airspy-fmradion
    git submodule init
    git submodule update
    mkdir build
    cd build
    ## if the script gets run again, clean up the previous build
    make clean
    cmake ..
    make && sudo make install
    ## create the udev rules for the airspyhf radio
    echo 'ATTR{idVendor}=="03eb", ATTR{idProduct}=="800c", SYMLINK+="airspyhf-%k", MODE="660", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/52-airspyhf.rules
    ## now reload the rules so they take effect
    sudo udevadm control --reload-rules && sudo udevadm trigger
    echo `date`
    echo "Clone and install the sdrstart.sh script and add to crontab...."
    ## get the sdrstart.sh script and put it in the proper spot
    cd ~
    git clone https://github.com/guitarpicva/sdrstart.git 
    chmod +x sdrstart/sdrstart.sh
    ## add the sdrstart.sh script to crontab -e
    MYPATH="$PATH"
    crontab -l > "$HOME/tmpcron.txt"
    CRONTMP=`cat "$HOME/tmpcron.txt"`
    if [[ "$CRONTMP" =~ ^[A-Za-z/_-]{,}sdrstart.sh+$ ]]
    then
        echo "Match!  Just leave it alone..."
    else
        echo "No Match: CLEAR CRONTAB FILE and add PATH and SDR line to crontab..."
        echo "PATH=$MYPATH" > "$HOME/tmpcron.txt"
        echo "* * * * * $HOME/sdrstart/sdrstart.sh" >> "$HOME/tmpcron.txt"
        crontab "$HOME/tmpcron.txt"
    fi
    rm -f "$HOME/tmpcron.txt"    
fi # for airspyhf section

echo `date`
echo "Clone and compile the Qt5.15.2 QtMqtt library...."
## First, clone and compile qt/qtmqtt 5.15.2
cd ~
mkdir src
cd src
git clone https://github.com/qt/qtmqtt.git -b 5.15.2
cd qtmqtt
mkdir build
cd build
qmake ..
make && sudo make install
echo `date`
echo "RPiOSLiteBuild.sh script finished!"
echo ""
echo ""
echo ""
echo ""
echo "YOU MUST REBOOT THE RPI NOW!!!!"
echo ""
echo ""
echo ""
echo ""
