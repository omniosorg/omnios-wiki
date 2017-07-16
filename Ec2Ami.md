Producing an EC2 AMI
====================

This is a process was originally developed by Andrzej Szeszo and
iterated upon by OmniT for creating a from-scratch AMI. Normally, users
would start with one of the [official AMIs](Installation.md#IntheCloud).

The attached files referred to below are on ticket [#17](https://omnios.omniti.com/ticket.php/17)

Getting an Initial Disk Image
-----------------------------

Install OmniOS in a VM (KVM, VMware, etc.). Create additional 8GB disk
and attach it to the VM.

Login and run the following commands, substituting the desired OS
release URL:

```
mkdir -p /var/kayak/kayak 
cd /var/kayak/kayak 
wget http://omnios.omniti.com/media/r151006c.zfs.bz2 
cd - 
pkg install git 
git clone anon@src.omniti.com:~omnios/core/kayak 
cd kayak
```

Fetch the ZFS-enabled pv-grub.gz.d3950d8 binary from
<http://omnios.omniti.com/media/pv-grub.gz.d3950d8>

pv-grub binary with zfs support was built from sources at [https://github.com/aszeszo/pv-grub](https://github.com/aszeszo/pv-grub) against [git://xenbits.xen.org/xen.git](git://xenbits.xen.org/xen.git)

Ensure that \$DISK variable in build\_xen.sh matches the secondary 8GB
disk device name.

Run:

```
./build_xen.sh
```

This will use the 8GB disk you created to install a working OS image
based on the Kayak-generated ZFS archive of the OS, complete with
pv-grub. At this point, you can shut down the OmniOS VM and move on to
the next steps.

Preparing the Disk Image for EC2
--------------------------------

Create a new VM with Ubuntu, Debian, or whatever your choice of
Linux-based Xen host you prefer. Configure the VM to add the above 8GB
disk you made for the OmniOS VM as an additional disk device. Your VM
system drive will need to be at least 10GB in size, and 16GB is a safe
size to assume.

Once your Linux VM is configured, installed, and booted into a Xen
kernel, you will want to dd the 8GB OmniOS drive to a file:

```
dd if=/dev/sdb of=omnios-r151006.raw bs=2048
```

With your raw image file of the OmniOS+pv-grub install, you must now use
Xen to correct the *phys\_path* attribute in *syspool*s disk label:

Every zpool has got *devid* and *phys\_path* values embedded in its
label. *phys\_path* value from the label is used to set bootpath= kernel
boot option when pv-grub is expanding \$ZFS-BOOTFS macro. The value
stored in the pool's label needs to match disk device name in EC2
environment. The OS used for preparing the disk image most likely stored
some pci device names in the label. When booted in EC2 environment,
first disk will be represented by `/xpvd/xdf@2048` device, second by
`/xpvd/xdf@2064` and so on.

Someone at Sun was looking for a tool that could be used to change the
values but such tool has never materialised. See here:
<http://www.mail-archive.com/zfs-discuss@opensolaris.org/msg26079.html>
Right now, the only way to change them is to import the pool in an
environment similar to EC2. So, to sort out the label, send generated
disk image to a Xen box (Debian+Xen 4.1, for example. Ubuntu
12.04LTS+Xen 4.2 works as well). I boot a temporary VM off of OI
text-install ISO and do a zpool import of syspool to correct the
*phys\_path* attribute.

Sample Xen config:

```
memory = 1024 
name = 'omnios' 
vcpus = 4 
disk = [ 'file:/root/omnios-r151006.raw,2048,w',
         'file:/root/oi-dev-151a5-text-x86.iso,2064,r' ] 
kernel = "/root/pv-grub.gz.d3950d8" 
extra = "(hd1)/boot/grub/menu.lst"
```

Attach to the domU console: `xm console <domain-id>`

When the GRUB menu appears, hit 'e' to edit the default entry, then 'O'
to add a new line above the first, and add “root (hd1)” on that line.

The menu should look like this:

```
root (hd1)
kernel$ /platform/i86pc/kernel/$ISADIR/unix
module$ /platform/i86pc/$ISADIR/boot_archive
```

Hit “Enter” then “b” to save the edited menu and boot. Don't worry about
the platform being “i86pc” instead of “i86xpv” (the paravirtualized
kernel). The custom pv-grub will take care of booting the proper PV
kernel.

The text installer CD will then boot into system maintenance mode where
you are prompted for a username and password, which for the OI installer
is root and no password.

Import the zpool with:

```
devfsadm
zpool import -R /a -f syspool
```

At this point the *phys\_path* info has been updated on the label.
Nothing more need be done so you can shut down the domU.

Getting The Image Into EC2
--------------------------

To create the actual AMI based on the prepared disk image, I normally
boot one of the existing Ubuntu AMIs on EC2, attach new volume to it and
then dd disk image over ssh to the attached volume. I take snapshot of
the volume and run the following command to create new AMI:

```
ec2reg --region <region-name> -a x86_64 -b /dev/sda=snap-XXXXXXXX --kernel aki-XXXXXXXX -n <custom-AMI-name>
```

Clean Up Instance For AMI Creation
----------------------------------

To make a fresh AMI from an existing instance, first clean it up to
remove instance-specific data.

Most importantly, remove ssh host keys:

```
rm -f /etc/ssh/ssh_host*
```

Delete any old BEs

```
beadm destroy <old-be-name>
```

Dump system logs:

```
rm -f /var/adm/messages.*
rm -f /var/log/syslog.*
cat /dev/null > /var/adm/messages
cat /dev/null > /var/log/syslog
cat /dev/null > /var/adm/wtmpx
cat /dev/null > /var/adm/utmpx
```

Clear FMA logs:

```
svcadm disable fmd
find /var/fm/fmd -type f -exec rm {} \;
svcadm enable fmd
fmadm reset eft
fmadm reset io-retire
```

Remove user ssh keys and root's bash history.

```
rm -rf /root/.ssh
rm -f /root/.bash_history
```

Sweep away your footprints just before logging out.

```
unset HISTFILE
history -c
```

Now power off your instance and create a AMI from it!

Misc notes
==========

Zpool Device Mismatch
---------------------

The following situation occurred with one of the early AMIs and
prevented a 'beadm activate' from working properly.

Zpool state:

```
        NAME           STATE     READ WRITE CKSUM
        syspool        ONLINE       0     0     0
          c3t2048d0s0  ONLINE       0     0     0
```

Upon doing a pkg update to a new BE:

```
/usr/bin/pkg update --be-name=omnios-r151004
...
(upgrade output)
...
pkg: unable to activate omnios-r151004
```

Drat.

```
beadm activate -v omnios-r151004
be_do_installgrub: installgrub failed for device c3t2048d0s0.
  Command: "/sbin/installgrub /tmp/tmpDLxHeH/boot/grub/stage1 /tmp/tmpDLxHeH/boot/grub/stage2 /dev/rdsk/c3t2048d0s0"
open: No such file or directory
Unable to gather device information for /dev/rdsk/c3t2048d0s0
be_run_cmd: command terminated with error status: 1
Unable to activate omnios-r151004.
Error installing boot files.
```

Eh?

```
ls -l /dev/rdsk/
total 11
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0p0 -> ../../devices/xpvd/xdf@2048:q,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0p1 -> ../../devices/xpvd/xdf@2048:r,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0p2 -> ../../devices/xpvd/xdf@2048:s,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0p3 -> ../../devices/xpvd/xdf@2048:t,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0p4 -> ../../devices/xpvd/xdf@2048:u,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0s0 -> ../../devices/xpvd/xdf@2048:a,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0s1 -> ../../devices/xpvd/xdf@2048:b,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0s10 -> ../../devices/xpvd/xdf@2048:k,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0s11 -> ../../devices/xpvd/xdf@2048:l,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0s12 -> ../../devices/xpvd/xdf@2048:m,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0s13 -> ../../devices/xpvd/xdf@2048:n,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0s14 -> ../../devices/xpvd/xdf@2048:o,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0s15 -> ../../devices/xpvd/xdf@2048:p,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0s2 -> ../../devices/xpvd/xdf@2048:c,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0s3 -> ../../devices/xpvd/xdf@2048:d,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0s4 -> ../../devices/xpvd/xdf@2048:e,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0s5 -> ../../devices/xpvd/xdf@2048:f,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0s6 -> ../../devices/xpvd/xdf@2048:g,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0s7 -> ../../devices/xpvd/xdf@2048:h,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0s8 -> ../../devices/xpvd/xdf@2048:i,raw
lrwxrwxrwx 1 root root 33 Sep 21 16:47 c1t2048d0s9 -> ../../devices/xpvd/xdf@2048:j,raw
```

WTF? How does this work?

# zdb -C syspool
zdb: can't open 'syspool': No such file or directory

```
zdb -C -l /dev/dsk/c1t2048d0s0
--------------------------------------------
LABEL 0
--------------------------------------------
    version: 28
    name: 'syspool'
    state: 0
    txg: 88185
    pool_guid: 11891920664759662147
    hostid: 9405301
    hostname: 'domU-12-31-39-0F-1C-BB.compute-1.internal'
    top_guid: 15601091898902222674
    guid: 15601091898902222674
    vdev_children: 1
    vdev_tree:
        type: 'disk'
        id: 0
        guid: 15601091898902222674
        path: '/dev/dsk/c3t2048d0s0'   <--- HERE
        phys_path: '/xpvd/xdf@2048:a'  <--- and HERE
        whole_disk: 0
        metaslab_array: 30
        metaslab_shift: 26
        ashift: 9
        asize: 8560050176
        is_log: 0
        create_txg: 4
    features_for_read:
...
```

OK, so ZFS also knows the physical path to the device, which is still
valid.

### How I Fixed It

On a physical system, I'd boot from the CD, drop to a shell, import
syspool and export it again. That would fix the device path in the zpool
labels. But this is EC2 so I have no access to the pre-boot environment.

Idea: attach mirror, resilver, detach orig, reattach under new device
name.

In essence: swing syspool to a temporary device which allows the
original disk to be detached and reattached, effecting the same change
as import/export.

So...

Made a second EBS volume of same size (8 GiB) and attached it.

```
       1. c1t2128d0 <Unknown-Unknown-0001 cyl 4096 alt 0 hd 128 sec 32>
          /xpvd/xdf@2128
```

Deliver the same partition layout as the original. Sometimes fmthard
complains, but so far this looks like just whining.

```
prtvtoc /dev/rdsk/c1t2048d0s2 | fmthard -s - /dev/rdsk/c1t2128d0s2
fmthard: Partition 2 specifies the full disk and is not equal
full size of disk.  The full disk capacity is 16777216 sectors.
fmthard:  New volume table of contents now in place.
```

Attach new device to make a mirror. Have to use the busted device name
as the source, because that's how ZFS knows this device right now.

```
zpool attach -f syspool c3t2048d0s0 c1t2128d0s0
```

I don't bother setting up boot blocks on the new device, as it's not
permanent. Once resilver is complete, the state:

```
        NAME             STATE     READ WRITE CKSUM
        syspool          ONLINE       0     0     0
          mirror-0       ONLINE       0     0     0
            c3t2048d0s0  ONLINE       0     0     0
            c1t2128d0s0  ONLINE       0     0     0
```

Now detach the mis-named device and re-attach under its correct name.

```
zpool detach syspool c3t2048d0s0
zpool attach -f syspool c1t2128d0s0 c1t2048d0s0
```

Once resilver is complete again, detach the temporary device.

```
zpool detach syspool c1t2128d0s0
```

And now the zpool has the proper idea of the device path.

```
        NAME           STATE     READ WRITE CKSUM
        syspool        ONLINE       0     0     0
          c1t2048d0s0  ONLINE       0     0     0
```

New BE activated and booted into successfully.
