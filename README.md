Examples on how to build an RPi4/5 for airspy-fmradion and direwolf connectivity in RPiOS Lite (headless)

PLEASE NOTE:  For RPiOS current (2025-02), libvolk2-dev is valid.

libvolk2 has been superceded by libvolk3 in Debian and derivatives for x86_64.  It will be necessary to manually compile libvolk v3.2 from the libvolk.org source repo.
Then compiling airspy-fmradion will find 3.2 in cmake step.  If libvolk.so.3.1.2 is needed for other programs make a symlink to libvolk.so.3.2.0.

HAMLIB: script shows ```-b 4.5.6``` but that switch might be omitted for getting the latest Hamlib
source code.

