Recovering from a too-large  file
================================

Method 1 - Use GRUB's command line to get you booted
----------------------------------------------------

##### NOTE - This method may not work if you have too many BEs. Experimental results have been mixed.

1. Make note of the BE name you wish to boot into. This BE should have
   working networking and the ability to ssh in, in case GRUB does not
   reset the console properly using this method. We will use “BEname” for
   this example.
2. Enter the GRUB command line. Its prompt is `grub> `
3. Set the boot ZFS filesystem as follows: `bootfs rpool/ROOT/BEname`
4. Reload an EMPTY configuration file, so the memory is cleaned up and
   reset, as follows: `configfile /dev/null`
5. Set the boot kernel as follows: `kernel$ /platform/i86pc/kernel/amd64/unix -B $ZFS-BOOTFS`
6. Set the boot archive as follows: `module$ /platform/i86pc/amd64/boot_archive`
7. Boot the system as follows: `boot`

In some of our testing on VMware Fusion, the console display would not
be set properly with this method. OmniOS, however, will come up. This is
why we recommend a BE that has known-working networking. Once OmniOS is
booted, you can use `beadm destroy OtherBEname` to eliminate BEs that are crowding up menu.lst.

Method 2 - use a ISO or USB to clean up 
----------------------------------------

1. You will have to boot off an ISO or a USB stick
2. Enter the shell
3. `mkdir /tmp/mnt`
4. `zpool import -R /tmp/mnt <root-pool-name>`
5. Edit `/tmp/mnt/<root-pool-name>/boot/grub/menu.lst` as follows

You will see a lot of entries grouped like this:

```
title r151012-Dec08-backup-1
bootfs rpool/ROOT/r151012-Dec08-backup-1
kernel$ /platform/i86pc/kernel/amd64/unix -B $ZFS-BOOTFS
module$ /platform/i86pc/amd64/boot_archive
#============ End of LIBBE entry =============
title r151012-Dec08-backup-2
bootfs rpool/ROOT/r151012-Dec08-backup-2
kernel$ /platform/i86pc/kernel/amd64/unix -B $ZFS-BOOTFS
module$ /platform/i86pc/amd64/boot_archive
#============ End of LIBBE entry =============
```

Those are two BE entries. You will need to remove BEs in five-line
groups, starting with the `title` line and ending with the `====` line. Make note of
which BE entries you are deleting, as you will need to explicitly delete
them upon reboot. Make sure you do not delete the BE you wish to enter.
ALSO, it is likely the “default” entry will be inaccurate after editing,
so use GRUB to explicitly pick your BE next boot.

After editing the menu.lst file down to a smaller size (30 entries or
less is a good rule of thumb, anything above 40 risks triggering this
problem), write out the smaller file in place.

6. `zpool export <root-pool-name>`
7. Reboot
8. When the GRUB menu comes up, make sure you're selecting your
   newly-created and updated BE
9. You will now have a booted system
10. Delete the BEs you edited out of menu.lst by using repeated
    instances of `beadm destroy <deleted-BE-name>`. This will
    destroy the datasets that back up the BEs you deleted from GRUB

The version of GRUB used in illumos does not scale well to multiple
entries, because of GRUB's poor memory management. It is the illumos
community's intention to eventually replace the current GRUB with
something better. Community contributions are, as always, welcome.
