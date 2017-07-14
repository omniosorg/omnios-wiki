Upgrading to r151014 or later.
==============================

One may upgrade any of r151006, r151008, r151010, r151012, or
r151013/bloody to r151014 or later. Upgrading from r151014 to a later
release can be simpler if [linked-image zones](linked_images.md) are
used.

A WARNING ABOUT NUMBER OF BOOT ENVIRONMENTS
-------------------------------------------

There is a known issue with grub and its memory management that limits
the number of boot environment entries in . This limit has been
shrinking as grub gets more features and bugfixes. If you are upgrading
from r151006 to r151014, this will be a large number.

If you have more than 38 Boot Environments, please go through and
destroy ones you don't need anymore **PRIOR TO UPGRADING**. (Use the
[beadm](http://illumos.org/man/1m/beadm) command - e.g. ' BENAME'.) The
experimental limits with the r151014 version of grub suggests 41 is the
upper limit of number of boot environments before grub cannot boot the
system. If you have more than 38 boot environments, we recommend
deleting enough to not break grub.

If you get your machine into a state where grub will not boot,
[there are two different recovery methods available](GrubTooManyBEs.md).

Performing the Upgrade (lipkg zones from a r151014 or later stable)
-------------------------------------------------------------------

If you have moved to [linked-image (lipkg)](linked_images.md)
non-global zones exclusively, the upgrade process can be simpler, modulo
some setup.

* If you wish to avoid a window of on-rpool log overflow between the old and new boot environments, disable any services that log in appropriate zones (including global)
* Make sure the global zone can reach the network
* Create a backup boot environment for safety (being careful of the number of BEs): `beadm create <appropriate-backup-name>`
* Change the publisher (as root or with privilege) in every zone root, including global. For example, going from r151014 to r151016:
  ```
  /usr/bin/pkg set-publisher -G http://pkg.omniti.com/omnios/r151014/ -g http://pkg.omniti.com/omnios/r151016/ omnios
  /usr/bin/pkg -R /zones/zone1/root set-publisher -G http://pkg.omniti.com/omnios/r151014/ -g http://pkg.omniti.com/omnios/r151016/ omnios
  /usr/bin/pkg -R /zones/zone2/root set-publisher -G http://pkg.omniti.com/omnios/r151014/ -g http://pkg.omniti.com/omnios/r151016/ omnios
  .  .  .
  ```
* If you have non-OmniOS IPS publishers, some of those packages may not yet be aware of r151016 and block the upgrade (e.g. some ms.omniti.com packages). Uninstall these ones prior to the update.
* Perform the update, optionally specifying the new BE name: `/usr/bin/pkg update {--be-name new-BE-name}`
* Reboot

**NOTE**: Once past a release migration, linked-image zones still offers
great convenience, because a single `pkg update` in the global zone easy
updates all linked-image zones.

Performing the Upgrade (all other cases, including lipkg if you wish)
---------------------------------------------------------------------

If you have non-global native (ipkg) zones, they must be shutdown and
detached at this time. **Even if you are used to updating zones after
`pkg upgrade` by using `pkg -R`, you MUST perform the upgrade this way,
because of the signature-policy changes.** (Bloody users, even
post-r151014 bloody, must do this too because of the signature policy
changes.) Once the global zone is updated and rebooted, the zones will
be upgraded as they are re-attached to the system. This is not necessary
for s10-branded zones or KVM guests.

After shutting down the zones gracefully (`zlogin <zonename>; shutdown -i5 -g0 -y`):

```
# /usr/sbin/zoneadm -z <zonename> detach
```

It would also be a good idea to take a ZFS snapshot of the zone root in
case it's needed for rollback (such as if there are issues with the zone
upgrade.) 

```
# /usr/sbin/zfs snapshot -r <zoneroot>@<old-release>
```

where <zoneroot> is the name of the ZFS dataset whose
mountpoint corresponds to the value of *zonepath* in the zone's
configuration. There are child datasets under this one, so we use the
`-r` option to recursively snapshot all.

Because each OmniOS release has its own dedicated repo, you will first
need to set the package publisher to the repository for r151016 (works
for r151014 as well from older version, just change 016 to 014):

```
# /usr/bin/pkg unset-publisher omnios
# /usr/bin/pkg set-publisher -P --set-property signature-policy=require-signatures -g http://pkg.omniti.com/omnios/r151016/ omnios
```

**NOTE: The “require-signatures” is new for r151014, and if you are upgrading this way it is up to you, the administrator, to make this change effective. If you are upgrading from r151014 or later, it's not needed, but stating it again will not hurt. The zone attach code will automatically match zone's publisher policies with the global zone. New zone creation after updating to r151014 will also apply the global zone's publisher policies on a per-publisher basis. If you have existing other publishers with or without signature policies, those publishers' signature policies will propagate into non-global zones.**

Update the global zone. The `--be-name` argument is optional, but it's nice to use a
name that's more meaningful than “omnios-N”. Add a `-nv` after the
'update' sub-command to do a dry run if you're unsure of what will
happen.

```
# /usr/bin/pkg update --be-name=omnios-r151014 entire@11,5.11-0.151014
```

This will create a new BE and install r151014 packages into it. When it
is complete, reboot your system. The new BE will now be the default
option in GRUB.

Once booted into your new r151014 BE, if you don't have non-global
zones, you are done with the upgrade.

If you have non-global native (ipkg) zones, you can either modify them
to become [linked-image zones](linked_images.md) (lipkg), or
continue on with non-linked images. If you wish to make a zone be a
linked-image one, change the brand PRIOR to attachment:

**NOTE: This is optional. Use only if you want <zonename> to be linked-image**

```
# /usr/sbin/zonecfg -z <zonename> set brand=lipkg
```

Attach each one with the `-u` option, which will upgrade the zone's core
packages to match the global zone.

```
# /usr/sbin/zoneadm -z <zonename> attach -u
```

Assuming the attach succeeds, the zone may be booted as usual:

```
# /usr/sbin/zoneadm -z <zonename> boot
```

Post-Upgrade (from pre-r151014 systems)
---------------------------------------

If you are running one or more instances of pkg.depotd(1M), then after
the upgrade you will need to refresh and clear them, as the name of the
start method has changed. This will cause the service(s) to be placed in
maintenance.

```
# svcadm refresh svc:/application/pkg/server:<your instance>
# svcadm clear svc:/application/pkg/server:<your instance>
```

Thanks to community member Volker Brandt for pointing this out!
