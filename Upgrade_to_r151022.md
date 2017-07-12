Upgrading to r151022.
=====================

One may upgrade any of r151014, r151020, or r151021/bloody to r151022.
It should be possible to upgrade directly from r151016 or r151018 as
well, but upgrading from these releases have not been tested.

Upgrading to the Very Latest
----------------------------

There are updates specifically out to insure a smooth upgrade to
r151022. The ca-bundle package MUST be updated on any release you have,
even ones officially EOSLed. Please make sure “pkg update -n” produces
no output and that “” shows an April 2017 timestamp. OpenSSH must also
replace SunSSH prior to an upgrade. See below for details.

Upgrading to OpenSSH from SunSSH
--------------------------------

SunSSH has been end-of-lifed in r151020 and later (including, of course,
r151022). To this end, either prior to the upgrade switch to OpenSSH:

Or add all of the options shown above to any commands below for
linked-image deployments. If you use non-linked image zones (ipkg), you
must update to SunSSH PRIOR to reboot.

Switching from SunSSH to OpenSSH will require commenting-out and options
from /etc/ssh/sshd\_config. Also both directives MUST be commented out
(SunSSH has one uncommented by default). There will be an
sshd\_config.new to consult, which comes from a fresh, unhindered
installation of OpenSSH.

Also, if you have entries in you may need to update them. For example,
one may need to to re-enable their two-factor authentication.

**ALL INSTALLATIONS WITH ZONES MUST** update all zones (including
global) to OpenSSH pre-upgrade. Even linked-image zones will require
per-zone installation, because of how SunSSH/OpenSSH were mediated prior
to SunSSH's end-of-life.

WARNING - DO NOT SWITCH TO LOADER IF YOU HAVE 4K LOGICAL SECTOR DISKS
---------------------------------------------------------------------

There is currently a bug in loader (https://www.illumos.org/issues/8303)
that will result in a non-bootable system if you have any pool (\*any\*
pool, not just your rpool) with 4K logical sector disks attached to the
system. Disks with 4K physical sectors and 512b logical sectors are ok,
but disks which have 4K logical sectors will fail. Follow the directions
listed in the \[wiki:BSDLoader Loader\] instructions to leave your
system configured with grub until this bug is fixed upstream and
backported to r151022. You can check your disks with the following
command:

It will return output like the following:

This is for a disk with a physical sector size of 4K (0x1000) and a
logical sector size of 512b (0x200), which is fine. If you see 0x1000
for the tgt or sys blocksize, you have a disk with 4K logical sector
size, DO NOT USE LOADER until this bug is fixed or your system will not
boot.

A \*NEW\* REMINDER ABOUT NUMBER OF BOOT ENVIRONMENTS
----------------------------------------------------

GREAT NEWS! Once you switch to \[wiki:BSDLoader Loader\] - there are no
limits on the number of boot environments you can have. Loader handles
any number of them.

If you are still using GRUB, however, and if you get your machine into a
state where grub will not boot, \[wiki:GrubTooManyBEs there are two
different recovery methods available\].

Performing the Upgrade (lipkg zones from a r151014 or later stable)
-------------------------------------------------------------------

**WARNING**: For the linked-images to upgrade, you MUST switch all zones
*pre-upgrade* to OpenSSH for this to work if you have not already. See
above for how to switch to OpenSSH. Please make sure all zones have
OpenSSH installed prior to following any directions below.

If you have moved to \[wiki:linked\_images linked-image (lipkg)\]
non-global zones exclusively, the upgrade process can be simpler, modulo
some setup.

`- If you wish to avoid a window of on-rpool log overflow between the old and new boot environments, disable any services that log in appropriate zones (including global).`

`- Make sure the global zone can reach the network.`

`- Create a backup boot environment for safety (being careful of the number of BEs):`

`- Change the publisher (as root or with privilege) in every lipkg zone root, and the global zone.  For example, going from r151014 to r151022:`

(NOTE: ipkg zones will get their publisher changed by the attach/detach
method below.)

`- If you have non-OmniOS IPS publishers, some of those packages may not yet be aware of r151022 and block the upgrade (e.g. some ms.omniti.com packages). Uninstall these ones prior to the update.`

`- Perform the update, optionally specifying the new BE name, and if you are on SunSSH, adding the `` arguments as well:`

`- Many times a BE is named after the release it's becoming.  For example:`

`- Reboot`

**NOTE**: Once past a release migration, linked-image zones continue to
offer great convenience, because a single “pkg update” in the global
zone easy updates all linked-image zones, if you use the “-r” flag.
Linked images have \[wiki:NewLinkedImages new behavior\] once you
upgrade to r151022, and requiring the use of “-r” is one of them.

Performing the Upgrade (ipkg zones only - **NEW METHOD**)
---------------------------------------------------------

**WARNING**: This is the ONLY method that works for ipkg zones now, due
to \[wiki:NewLinkedImages pkg(5) changes\]. For the detach/attach method
of upgrade, you MUST switch all zones *pre-upgrade* to OpenSSH for this
to work if you have not already. See above for how to switch to OpenSSH.
Please make sure all zones have OpenSSH installed prior to following any
directions below.

If you have non-global native (ipkg) zones, they must be shutdown and
detached at this time.

**LX Zones are not upgraded individually. Their native bits are directly
inherited from the global zone, and Linux bits should be updated while
running inside the zone.**

After shutting down the zones gracefully (zlogin; shutdown -i5 -g0 -y):

It would also be a good idea to take a ZFS snapshot of the zone root in
case it's needed for rollback (such as if there are issues with the zone
upgrade.) where <zoneroot> is the name of the ZFS dataset whose
mountpoint corresponds to the value of *zonepath* in the zone's
configuration. There are child datasets under this one, so we use the
option to recursively snapshot all.

Because each OmniOS release has its own dedicated repo, you will first
need to set the package publisher to the repository for r151022:

Update the global zone. The argument is optional, but it's nice to use a
name that's more meaningful than “omnios-N”. Add a '-nv' after the
'update' sub-command to do a dry run if you're unsure of what will
happen. **REMEMBER** - You must change to OpenSSH first before using
this method.

This will create a new BE and install r151022 packages into it. When it
is complete, reboot your system. The new BE will now be the default
option in GRUB.

Once booted into your new r151022 BE, if you don't have non-global
zones, you are done with the upgrade.

Attach each ipkg zone. **NOTE: This will fail due to the Python 2.6
-&gt; 2.7 migration. DO NOT PANIC.** The zone's publisher will have been
updated, and it will be mounted in /zones/<zonename>/root/, however.

Next, use the -R option to pkg(1M) and force-upgrade the zone

If you'd forgotten to upgrade your zone to OpenSSH, you will have to
revert to your old BE and start over. Make sure you first set the
current BE to use grub:

Finally, attach the zone to reality check its integrity:

The attach should be quick, as the upgrade already happened. The zone is
now updated and ready to boot.
