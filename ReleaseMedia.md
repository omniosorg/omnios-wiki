Preparing Release Media
=======================

How to make the release images. If any of these are created, *all*
should be created so that we remain consistent.

Kayak
-----

Kayak builds require a global zone with no non-global zones configured.
As of \[wiki:ReleaseNotes/r151022 r151022\] Kayak now generates ALL of
the OmniOS release media.

Check out the [source](https://github.com/omniti-labs/kayak), **ensuring
that it is the branch matching the release you're building for**,
install gnu-make, cdrtools, and if this isn't the first time you've make
Kayak media on this host:

Then (as root or with sudo):

The install-usb target is dependent on all of the other media. When you
are done, you will see:

||file||purpose|| || || || ||||The PXE boot miniroot that also forms the
ISO/USB miniroot|| ||||The compressed ZFS send stream that Kayak
installers spray onto a new rpool.|| ||||The ISO image for the
\[wiki:KayakInteractive Kayak Interactive Installer\].|| ||||The USB
stick image (using dd(1) for the \[wiki:KayakInteractive Kayak
Interactive Installer\].||

Publishing Media Files
----------------------

Copy the media files to the \`omnios.omniti.com\` webserver, placing
them in the media directory. Don't forget to
\[wiki:WeeklyReleaseHowto\#Updatingsymlinks update symlinks\].
