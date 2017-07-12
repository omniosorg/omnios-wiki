While the recommended way to customize rpool configuration is to utilize
a network install with kayak, putting together a complete dhcp/tftp/http
network install environment is a bit overkill for installing one box or
doing some testing.

Instead, you can use this small perl script (attached) that interposes
itself between the installer and the zpool creation allowing some basic
customizations while doing an iso install.

Boot the installer media, and pick option 3/shell prior to beginning the
install. Get the attached script into /tmp one way or another (light up
the network interface and suck it over with wget, for example) and make
it executable. Execute /tmp/omnios\_zpool\_install.pl (note: use fully
qualified path, not relative path) and it will copy the zpool/zfs
binaries into /tmp and install itself in their place with an overlay
mount.

Edit the script to configure what customizations you might want to make.
The first option is if you want to use less than the entire disk for the
rpool. If enabled, s0 on the installation device will be modified to the
size specified. The second option allows you to provide any arbitrary
zpool options to the zpool create (for example, to enable compression).
The last two options allow you to specify the size of swap/dump
explicitly rather than using the installer generated values.

Exit the shell and go back to the installer, and start the installation.
Proceed through as normal, and when it is done, the created rpool should
include the customizations you picked.

After the install is complete, the file /tmp/omnios\_zpool\_install.log
contains a rough log of what commands the installer tried to run and
what commands were run instead. If you enabled the rpool size option,
there will also be a file /tmp/format.out containing the output from
format when trying to resize the slice. If the end result isn't what you
expected, one of those might contain a clue as to what went wrong.
