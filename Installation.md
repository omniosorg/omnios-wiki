Installing OmniOS
=================

OmniOS is designed to be run on server class systems rather than laptops
or generic workstations. You may have luck with this hardware, but there
is a good chance you will find your hardware unsupported.

A list of supported hardware is on the [illumos Hardware Compatibility
List](http://illumos.org/hcl)

If you find yourself with hardware for which drivers are not present in
the standard release, you may install drivers yourself by dropping out
to a shell and installing the drivers manually. Please note that while
the installation menu offers a selection for installing additional
drivers, this functionality is not present in the OmniOS installer, and
will be removed shortly.

Quickstart
----------

`* `[`Vagrant`` ``Boxes`](https://atlas.hashicorp.com/omnios)\
`` * If you're using vagrant <= 1.2.2, this requires the vagrant-guest-omnios plugin (`vagrant plugin install vagrant-guest-omnios`) ``

From CD/iso
-----------

`* Get the ISO file for the desired release:`\
`  * Current stable and LTS release (r151022, omnios-r151022-f9693432c2): `[`1`](http://omnios.omniti.com/media/r151022.iso)[`br`](br "wikilink")\
`    `\
`  * Bloody release (r151023, omnios-master-8b31933c62): `[`2`](http://omnios.omniti.com/media/r151023-20170515.iso)[`br`](br "wikilink")\
`    `

`* Boot the disk and follow the directions [wiki:KayakInteractive here].  Aside from creating an rpool upon which to install, and a timezone, there are no options.  All configuration of the system happens on first boot by you: the administrator.  You use the same tools to initially configure the machine as you would for ongoing maintenance.`\
`* By default, the system installs a root user with a blank password and with no networking configured.  This makes logging in via console supremely simple and logging in remotely simply impossible.  Once you've logged in the first time, you can set a root password with the `` command.  If you wish, enable remote root login via ssh by editing the `` file and changing the `` option to ``; do so at your own risk.  The same risks apply to any post-installation/pre-reboot changes done via the installer shell.`

From USB
--------

`* Just like CD images:`\
`  * Current stable and LTS (r151022, omnios-r151022-f9693432c2): `[`3`](http://omnios.omniti.com/media/r151022.usb-dd)[`br`](br "wikilink")\
`    `\
`  * Bloody release (r151023, omnios-master-8b31933c62): `[`4`](http://omnios.omniti.com/media/r151023-20170515.usb-dd)[`br`](br "wikilink")\
`    `

These images may be written to your USB drive with dd, like so:

Where is the base device (e.g., in Linux, in MacOS X, and in illumos.
It's **very** important that you use rdsk instead of dsk; your USB won't
boot otherwise!)

Boot and follow the same directions as for CD/iso above (i.e. using the
\[wiki:KayakInteractive Kayak Interactive Installer\]).

Using Vagrant
-------------

[Vagrant](http://vagrantup.com) is a system for managing and
provisioning virtual machines with tools like
[Chef](http://www.opscode.com/chef/),
[Ansible](http://www.ansible.com/home), and
[Puppet](https://puppetlabs.com/). It's an easy way to try out an OmniOS
system.

Unless otherwise noted, all baseboxes feature:

`* 40 GB disk allocated as a single zpool.`\
`* Vagrant default insecure ssh keys, with password-less sudo.`\
`* omniti-ms publisher.`

To use OmniOS Vagrant baseboxes, we strongly recommend that you refer to
boxes we provide through the Atlas catalogue. Only the baseboxes
provided under the \`omnios/\` namespace are official. We use a standard
naming scheme for all of our baseboxes, which is simply the release
number or name. Thus, our current LTS release's basebox is named
\`omnios/r151014\` and the bloody release is \`omnios/bloody\`.

[OmniOS Baseboxes on Atlas](https://atlas.hashicorp.com/omnios)

Our baseboxes also use a semantic versioning scheme where the major
version is the release number (minus the “r”), the minor version is the
ISO install media sequence number, and the patch version is incremented
whenever we create a new basebox from the same ISO install media
(generally for minor fixes or updates to pre-installed packages). Our
bloody release's basebox is the only exception, since it has no release
number - instead, the basebox version is simply the \$year.\$month.\$day
of the bloody install media from which the basebox was created.

Getting started with one of our baseboxes is as simple as (shown here
for r151014):

Please note that we no longer provide Chef Solo as part of the default
install on any of our baseboxes, and instead recommend using the shell
provisioner to bootstrap your choice of configuration management tools.
Additionally, beginning with our baseboxes for r151014, we no longer
install (or support) !VirtualBox Guest Additions due to
incompatibilities.

In the Cloud
------------

**NOTE:** Be sure to consult
[here](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html)
to know how to find a community AMI, like ours.

OmniOS AMI names are of the form:[BR](BR "wikilink")
[BRWe](BR "wikilink") provide the AMI Names below. (Note that AMI IDs
are specific to region.)

**Amazon Public AMIs for OmniOS**

|| **Region** || **AMI Name** || || all regions || OmniOS r151006 LTS
20160520 || || all regions || OmniOS r151014 LTS 20170427 || || all
regions || OmniOS r151014 LTS OpenSSH 20170427 || || all regions ||
OmniOS r151020 Stable 20170427 || || all regions || OmniOS r151022 LTS
20170515 ||

From the network
----------------

The [Kayak](http://omnios.omniti.com/browse.php/core/kayak) network
installer enables installation over a network utilizing PXE, DHCP and
HTTP. It is a replacement for Solaris Automated Installer (AI) that
delivers some new features:

`* Support for mirrored rpool`\
`* ZFS compression on by default for rpool`\
`* Installation image delivered as ZFS dataset`

Kayak comes with a working boot kernel and miniroot, but you will need
to create the installation image yourself.

### Set up a Kayak server

`* Install Kayak server and kernel files:`\
`  `\
`* `**`(r151014`` ``and`` ``earlier)`**` Activate TFTP server by adding the following line to `` and running the `“`inetconv`”` command.  This will create an SMF service, ``.  Note that `“`udp6`”` nevertheless serves BOTH IPv4 and IPv6.`\
`  `\
`* `**`(r151016`` ``and`` ``later)`**` Activate the TFTP server (note that `“`udp6`”` nevertheless serves BOTH IPv4 and IPv6):`\
`  `\
`* Activate the Kayak service.  This provides an HTTP server which serves files from ``.  Client installation logs will be uploaded to ``.  Available installation images, client configs and logs will be visible from the main index page.`\
`  `\
`* Fetch the ZFS installation image.  This is a ZFS root filesystem from a default installation.  During Kayak installation this is decompressed and received to create the local root filesystem.  Save the bzip file to ``.  It should appear under `“`Available`` ``Images`”` on your server's index page.`\
`  * Current stable and LTS: `[`5`](http://omnios.omniti.com/media/r151022.zfs.bz2)[`br`](br "wikilink")\
`    `\
`  * Bloody: `[`6`](http://omnios.omniti.com/media/r151023-20170515.zfs.bz2)[`br`](br "wikilink")\
`    `\
`* If this is not the same OS version as your kayak host, you may need to update /tftpboot/boot/grub/menu.lst to include your new image.`\
`* `**`(OPTIONAL)`**` Create the installation image if you don't wish to use the one provided.  This requires a ZFS dataset to act as a container for the image.  The image will be placed in `` as ``  Note that because this step manipulates kernel drivers as part of building the image, it must be run in the global zone.  If you want to use a non-global zone as your Kayak server, you can do the build step on a global zone and copy the file to the Kayak server.`\
`  `\
`* Available, but not fully tested, is also the [wiki:BSDLoader illumos/BSD Loader] for PXE boot.`

With a little reorganization, you can also \[wiki:KayakMultiRelease
serve multiple OS releases from one Kayak server\]

TODO: show how to customize the installation image above and beyond the
“entire” incorporation.

### Set up a Kayak client config

Kayak client configs are snippets of bash script that get executed
during installation.

`* On your Kayak server, copy `` to a file in `` with a name matching the hex values of the client's MAC address in all caps, e.g. `“`010203ABCDEF`”`.`\
`* Edit this file as needed.  See the [wiki:KayakClientOptions client documentation] for details on the possible settings.`

### Install a client

Configure your DHCP server to direct the client to the Kayak server's
address and set the boot file to be “pxegrub”.

If you are using ISC DHCP, the entry for your host might look like:

Where is the IP of your Kayak server.

PXE-boot the client. To avoid an endless loop of installation, do not
make network the default boot device. Most server firmware allows a
certain keypress to modify the boot order temporarily, such as F11 or
F12.

The installer will attempt to bring up all available network interfaces
and will attempt DHCP configuration on all of them in parallel. If your
system is connected to multiple networks that contain DHCP servers, you
may get undesirable results.

If the installation succeeds, the client reboots unless NO\_REBOOT is
set in the client config. If installation fails, you can get a shell
prompt by entering the username “root” and a blank password. Once you
have finished, either reset the system power or reboot with:

The usual 'reboot' command is non-functional in the miniroot
environment.

### In A Non-OmniOS Environment

If you already have a PXE setup on another platform, you can set it up
to install OmniOS clients. See \[wiki:PXEfromNonOmniOS\] where Gavin
Sandie shows how he set it up in a Debian environment.

Post-Install
------------

See the \[wiki:GeneralAdministration Admin Guide\] for post-install
steps, and the MoreInfo page for links to external sources of additional
documentation.

If you used the ISO installer and want to set up a mirrored root pool,
see \[wiki:GeneralAdministration\#MirroringARootPool Mirroring A Root
Pool\]
