Producing an EC2 AMI
====================

This is a process was originally developed by Andrzej Szeszo and
iterated upon by OmniT for creating a from-scratch AMI. Normally, users
would start with one of the \[wiki:Installation\#IntheCloud official
AMIs\].

The attached files referred to below are on ticket \#17

Getting an Initial Disk Image
-----------------------------

Install OmniOS in a VM (KVM, VMware, etc.). Create additional 8GB disk
and attach it to the VM.

Login and run the following commands, substituting the desired OS
release URL:

Fetch the ZFS-enabled pv-grub.gz.d3950d8 binary from
<http://omnios.omniti.com/media/pv-grub.gz.d3950d8>

`- pv-grub binary with zfs support was built from sources at `[`https://github.com/aszeszo/pv-grub`](https://github.com/aszeszo/pv-grub)` against `[`git://xenbits.xen.org/xen.git`](git://xenbits.xen.org/xen.git)

Ensure that \$DISK variable in build\_xen.sh matches the secondary 8GB
disk device name.

Run:

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

With your raw image file of the OmniOS+pv-grub install, you must now use
Xen to correct the *phys\_path* attribute in *syspool*s disk label:

Every zpool has got *devid* and *phys\_path* values embedded in its
label. *phys\_path* value from the label is used to set bootpath= kernel
boot option when pv-grub is expanding \$ZFS-BOOTFS macro. The value
stored in the pool's label needs to match disk device name in EC2
environment. The OS used for preparing the disk image most likely stored
some pci device names in the label. When booted in EC2 environment,
first disk will be represented by device, second by and so on.

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

Attach to the domU console:

When the GRUB menu appears, hit 'e' to edit the default entry, then 'O'
to add a new line above the first, and add “root (hd1)” on that line.

The menu should look like this:

Hit “Enter” then “b” to save the edited menu and boot. Don't worry about
the platform being “i86pc” instead of “i86xpv” (the paravirtualized
kernel). The custom pv-grub will take care of booting the proper PV
kernel.

The text installer CD will then boot into system maintenance mode where
you are prompted for a username and password, which for the OI installer
is root and no password.

Import the zpool with:

At this point the *phys\_path* info has been updated on the label.
Nothing more need be done so you can shut down the domU.

Getting The Image Into EC2
--------------------------

To create the actual AMI based on the prepared disk image, I normally
boot one of the existing Ubuntu AMIs on EC2, attach new volume to it and
then dd disk image over ssh to the attached volume. I take snapshot of
the volume and run the following command to create new AMI:

Clean Up Instance For AMI Creation
----------------------------------

To make a fresh AMI from an existing instance, first clean it up to
remove instance-specific data.

Most importantly, remove ssh host keys:

Delete any old BEs

Dump system logs:

Clear FMA logs:

Remove user ssh keys and root's bash history.

Sweep away your footprints just before logging out.

Now power off your instance and create a AMI from it!

Misc notes
==========

Zpool Device Mismatch
---------------------

The following situation occurred with one of the early AMIs and
prevented a 'beadm activate' from working properly.

Zpool state:

Upon doing a pkg update to a new BE:

Drat.

Eh?

WTF? How does this work?

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

Deliver the same partition layout as the original. Sometimes fmthard
complains, but so far this looks like just whining.

Attach new device to make a mirror. Have to use the busted device name
as the source, because that's how ZFS knows this device right now.

I don't bother setting up boot blocks on the new device, as it's not
permanent. Once resilver is complete, the state:

Now detach the mis-named device and re-attach under its correct name.

Once resilver is complete again, detach the temporary device.

And now the zpool has the proper idea of the device path.

New BE activated and booted into successfully.
