Kayak Interactive Installer
===========================

Starting with r151022, the ISO and USB interactive installers are new.
They install on whole-disks, and multiple disks can be selected to make
mirrored rpools. Also, blkdev devices (e.g. NVMe, vioblk) can now be
detected. Custom rpools can also be built, and the installer can just
install the bits on a preconfigured rpool.

BSD Loader Menu
---------------

See the [Loader usage documentation](BSDLoader.md#InteractingwithLoader).
The new ISO/USB media for r151022 and later will boot with the Loader
instead of GRUB.

Language Selection and Main Menu
--------------------------------

Like the old installer, the first thing to come up after boot is the
keyboard-layout selector:

![Keyboard-layout selector](Images/keyboard_layout_selector.png)

And then the installer displays its main menu:

![Installer main menu](Images/installer_main_menu.png)

The first two items are for installing on to a new root pool `rpool` . The first
one goes through disk-selection (see below) followed by an installation,
the second assumes `rpool` was constructed already, and proceeds straight to it.
For cases where the rpool is comprised of mirrored slices (for example,
to split an SSD pair between slog and rpool), the second entry should be
selected.

Before this installer, certain tricks like [this](ISOrpoolCustomize.md)
needed to be used. Now, one can use the Shell first (option 3) to
create a custom rpool as well as anything else, and then use the
straight-to-pool (option 2) method for installing on the rpool. The
Shell can also be used post-installation (see below).

Disk Selection
--------------

Available disks are displayed seven (7) at a time on one screen:

![Available disks](Images/available_disks.png)

Multiple disks selected will form an N-way mirror. Only a mirror or a
single-disk pool can serve as an rpool.

![Multiple disks selected](Images/multiple_disks_selected.png)

Installation
------------

After rpool creation, the installer will prompt for a few more
questions, including time-zone selection. Then it will `zfs receive` an on-media ZFS
send stream to create `rpool/ROOT/omnios`, the first Boot Environment (BE) on this `rpool`. It
will also create swap and dump datasets on `rpool`.

Post-install
------------

After installation, the main menu returns. The shell is still available,
and the new `rpool` is mounted on `/mnt` for further editing. `/mnt/.initialboot` contains commands that
will run exactly once at first-boot time. Network configuration could be
done here, for example. Other configuration on `/mnt/etc` could be done at this
time as well via the shell. Once the machine reboots, the
newly-installed rpool will display [Loader](BSDLoader.md) and then
boot into the newly-installed BE.
