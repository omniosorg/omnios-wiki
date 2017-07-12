Kayak Interactive Installer
===========================

Starting with r151022, the ISO and USB interactive installers are new.
They install on whole-disks, and multiple disks can be selected to make
mirrored rpools. Also, blkdev devices (e.g. NVMe, vioblk) can now be
detected. Custom rpools can also be built, and the installer can just
install the bits on a preconfigured rpool.

BSD Loader Menu
---------------

See the \[wiki:BSDLoader\#InteractingwithLoader Loader usage
documentation\]. The new ISO/USB media for r151022 and later will boot
with the Loader instead of GRUB.

Language Selection and Main Menu
--------------------------------

Like the old installer, the first thing to come up after boot is the
keyboard-layout selector:

[Image(Screen Shot 2017-04-25 at 1.35.26
AM.png)](Image(Screen_Shot_2017-04-25_at_1.35.26_AM.png) "wikilink")

And then the installer displays its main menu:

[Image(Screen Shot 2017-04-25 at 1.35.46
AM.png)](Image(Screen_Shot_2017-04-25_at_1.35.46_AM.png) "wikilink")

The first two items are for installing on to a new root pool . The first
one goes through disk-selection (see below) followed by an installation,
the second assumes was constructed already, and proceeds straight to it.
For cases where the rpool is comprised of mirrored slices (for example,
to split an SSD pair between slog and rpool), the second entry should be
selected.

Before this installer, certain tricks like \[wiki:ISOrpoolCustomize
this\] needed to be used. Now, one can use the Shell first (option 3) to
create a custom rpool as well as anything else, and then use the
straight-to-pool (option 2) method for installing on the rpool. The
Shell can also be used post-installation (see below).

Disk Selection
--------------

Available disks are displayed seven (7) at a time on one screen:

[Image(Screen Shot 2017-04-25 at 1.36.08
AM.png)](Image(Screen_Shot_2017-04-25_at_1.36.08_AM.png) "wikilink")

Multiple disks selected will form an N-way mirror. Only a mirror or a
single-disk pool can serve as an rpool.

[Image(Screen Shot 2017-04-25 at 1.36.53
AM.png)](Image(Screen_Shot_2017-04-25_at_1.36.53_AM.png) "wikilink")

Installation
------------

After rpool creation, the installer will prompt for a few more
questions, including time-zone selection. Then it will an on-media ZFS
send stream to create , the first Boot Environment (BE) on this . It
will also create swap and dump datasets on .

Post-install
------------

After installation, the main menu returns. The shell is still available,
and the new is mounted on for further editing. contains commands that
will run exactly once at first-boot time. Network configuration could be
done here, for example. Other configuration on could be done at this
time as well via the shell. Once the machine reboots, the
newly-installed rpool will display \[wiki:BSDLoader Loader\] and then
boot into the newly-installed BE.
