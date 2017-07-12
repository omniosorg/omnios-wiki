illumos Loader (aka. “BSD Loader”)
==================================

Starting with r151022, the new illumos boot loader, ported from FreeBSD,
is the default boot loader. Existing installations that use “” will
continue to use GRUB for at least one reboot, though.

New OmniOS installations
------------------------

A new OmniOS installation of r151022 or later will install with Loader
as the boot loader. It is possible to revert to GRUB in r151022, but
GRUB is likely to be removed in a post-r151022 Stable release, and
should be considered deprecated for new installations.

Existing OmniOS installations
-----------------------------

After a “pkg update” to r151022, the next system boot will still be on
GRUB. This is because [beadm](http://illumos.org/man/1m/beadm) is still
the pre-r151022 version. After you boot into r151022, the next
[beadm](http://illumos.org/man/1m/beadm) operation will install loader
unless /etc/default/be indicates otherwise.

### I WANT TO MOVE TO LOADER AFTER UPDATE

#### WARNING - DO NOT SWITCH TO LOADER IF YOU HAVE 4K LOGICAL SECTOR DISKS

There is currently a bug in loader (https://www.illumos.org/issues/8303)
that will result in a non-bootable system if you have any pool (\*any\*
pool, not just your rpool) with 4K logical sector disks attached to the
system. Disks with 4K physical sectors and 512b logical sectors are ok,
but disks which have 4K logical sectors will fail. Follow the directions
listed in the [Loader](BSDLoader.md) instructions to leave your
system configured with grub until this bug is fixed upstream and
backported to r151022. You can check your disks with the following
command:

```
echo ::sd_state | mdb -k | egrep '(^un|_blocksize)'
```

It will return output like the following:

```
un 1: ffffff0d0c58cd40                                                          
    un_sys_blocksize = 0x200                                                    
    un_tgt_blocksize = 0x200                                                    
    un_phy_blocksize = 0x1000                                                   
    un_f_tgt_blocksize_is_valid = 0x1
```

This is for a disk with a physical sector size of 4K (0x1000) and a
logical sector size of 512b (0x200), which is fine. If you see 0x1000
for the tgt or sys blocksize, you have a disk with 4K logical sector
size, DO NOT USE LOADER until this bug is fixed or your system will not
boot.

#### Moving to loader

This is the default after updating, but Loader does not get installed
until you ```beadm activate``` a loader-friendly BE (including the current one). Reboots
after an update without the invocation of ```beadm activate``` or
[installboot](http://illumos.org/man/1m/installboot) will mean your
machine stays with grub. You should notice an extra message about ```/rpool/boot/menu.lst``` being
created if loader is installed for the very first time on a root pool.

An old BE CAN be booted from the new Loader menu, but beadm will not
work properly in that pre-Loader boot environment once booted.

### I WANT TO STAY WITH GRUB AFTER UPDATE

Put ```BE_HAS_GRUB=true``` into ```/etc/default/be``` on your current r151022 boot environment. This will instruct
beadm(1M) and libbe that you wish to continue with GRUB. Pre-r151022 BEs
will work fine, and you can ```beadm activate``` between all of them.

### OH NO, I WANT TO CHANGE MY MIND

Sometimes people make a mistake when selecting which loader to use. For
the lifetime of r151022, such a mistake can be rectified, so long as one
of the other boot environments is not a post-r151022 with GRUB removed.

#### I WAS USING GRUB, BUT WANT TO SWITCH TO LOADER

* Remove ```/etc/default/be``` on an active r151022 BE
* ```beadm activate <current-BE>``` -- you should see a message about ```/rpool/boot/menu.lst``` being created
* You are now on loader!

If the ```beadm activate``` fails, or you still are booting with GRUB afterwards, explicitly install loader by:

```
rm /etc/default/be
installboot -m /boot/pmbr /boot/gptzfsboot /dev/rdsk/<rpool-drive>
rm /rpool/boot/menu.lst
beadm activate <current-BE>  (should reconstruct /rpool/boot/menu.lst)
```

If you have mirrored roots, do the above installboot for each ```<rpool-drive>```.

#### I WAS USING LOADER, BUT WANT TO REVERT TO GRUB

* You will need to be in an active 2017 bloody BE.
* Invoke the following:

```
rm /rpool/boot/menu.lst
echo "BE_HAS_GRUB=true" > /etc/default/be
installgrub -m /boot/grub/stage1 /boot/grub/stage2 /dev/rdsk/<rpool-drive>
```

If you have mirrored roots, use ```installgrub -M /dev/rdsk/<installed-drive> /dev/rdsk/<mirror-drive>```

Interacting with Loader
-----------------------

The Loader main screen looks like this:

![Image(Screen Shot 2017-04-19 at 5.42.17PM.png)](Images/Screen\ Shot\ 2017-04-19\ at\ 5.42.17\ PM.png)

Normally a 10-second countdown will display at the bottom, and if
nothing is done, OmniOS itself will boot. This screen provides all of
the pre-boot functionality, including an interactive forth interpreter
in the “Loader Prompt”.

ALL loader screens will boot OmniOS upon the press of RETURN.

### Boot Options

The Boot Options screen looks like this:

![Image(Screen Shot 2017-04-19 at 5.49.18PM.png)](Images/Screen\ Shot\ 2017-04-19\ at\ 5.49.18\ PM.png)

It allows the setting of debug-message boots, pre-loading of KMDB, and
redirecting the console output.

ALL loader screens will boot OmniOS upon the press of RETURN.

### Selecting a Boot Environment

Unlike GRUB, loader does not have any unusually small memory limits on
number of selectable boot environments. They are displayed five at a
time as follows:

![Image(Screen Shot 2017-04-19 at 5.50.56PM.png)](Images/Screen\ Shot\ 2017-04-19\ at\ 5.50.56\ PM.png)

Like GRUB, a selected BE is NOT marked for persistent default. Only
OmniOS's (1M) command can do that.

ALL loader screens will boot OmniOS upon the press of RETURN.
