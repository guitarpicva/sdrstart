Examples on how to build an RPi4/5 for airspy-fmradion and direwolf connectivity in RPiOS Lite (headless)

PLEASE NOTE:  libvolk2 has been superceded by libvolk3 in Debian x86_64 and derivatives.
For RPiOS current (2025-02), libvolk2-dev is valid.
It will be necessary to maunally compile libvolk v3.2 from the libvolk.org source repo.
Then compiling airspy-fmradion will find 3.2 in cmake step.

HAMLIB: script shows brand 4.5.6 but that switch might be omitted for getting the latest Hamliv
source code.

