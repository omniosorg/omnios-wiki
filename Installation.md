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

* [Vagran Boxes](https://atlas.hashicorp.com/omnios)
* If you're using vagrant <= 1.2.2, this requires the vagrant-guest-omnios plugin
  (`vagrant plugin install vagrant-guest-omnios`)

From CD/iso
-----------

Get the ISO file for the desired release:

[Current stable and LTS release (r151022, omnios-r151022-f9693432c2)](http://omnios.omniti.com/media/r151022.iso)

```
md5 (r151022.iso) = 3227b314c445d402e9907fdf4ddeda51
sha1 (r151022.iso) = a4e71e0b82416750ed069549b84f265c49b0ace9
sha256 (r151022.iso) = 47e24f71bf4f6a51672ee4ab3ec05b4b32fcd2247e278cb64d143f021c62a382
```

[Bloody release (r151023, omnios-master-8b31933c62)](http://omnios.omniti.com/media/r151023-20170515.iso)

```
md5 (r151023-20170515.iso) = 4fffde51e96b767d790faf1593c35432
sha1 (r151023-20170515.iso) = a6391a1bc9410b594371a2f91ce43b633638d2e3
sha256 (r151023-20170515.iso) = 06bf157e38b844d1d07ae292c6b91a6a60f0b2bbb4e1097e053dbf5c38a2f933
```

Boot the disk and follow the directions [here](KayakInteractive.md). Aside from creating
an rpool upon which to install, and a timezone, there are no options. All configuration
of the system happens on first boot by you: the administrator. You use the same tools to
initially configure the machine as you would for ongoing maintenance.

By default, the system installs a root user with a blank password and with no networking
configured. This makes logging in via console supremely simple and logging in remotely
simply impossible. Once you've logged in the first time, you can set a root password with
the `passwd` command. If you wish, enable remote root login via ssh by editing the
`/etc/ssh/sshd_config` file and changing the `PermitRootLogin` option to `yes`; 
**do so at your own risk**.
The same risks apply to any post-installation/pre-reboot changes done via the installer shell.

From USB
--------

Just like CD images:

[Current stable and LTS (r151022, omnios-r151022-f9693432c2)](http://omnios.omniti.com/media/r151022.usb-dd)

```
md5 (r151022.iso) = 3227b314c445d402e9907fdf4ddeda51
sha1 (r151022.iso) = a4e71e0b82416750ed069549b84f265c49b0ace9
sha256 (r151022.iso) = 47e24f71bf4f6a51672ee4ab3ec05b4b32fcd2247e278cb64d143f021c62a382
```

[Bloody release (r151023, omnios-master-8b31933c62)](http://omnios.omniti.com/media/r151023-20170515.usb-dd)

```
md5 (r151023-20170515.iso) = 4fffde51e96b767d790faf1593c35432
sha1 (r151023-20170515.iso) = a6391a1bc9410b594371a2f91ce43b633638d2e3
sha256 (r151023-20170515.iso) = 06bf157e38b844d1d07ae292c6b91a6a60f0b2bbb4e1097e053dbf5c38a2f933
```

These images may be written to your USB drive with dd, like so:

```
dd if=/path/to/image.usb-dd of=/path/to/device bs=1M
```

Where `/path/to/device` is the base device (e.g., `/dev/sdc` in Linux,
`/dev/disk2` in MacOS X, and `dev/rdsk/c0t0d0p0` in illumos.
It's **very** important that you use rdsk instead of dsk; your USB won't
boot otherwise!)

Boot and follow the same directions as for CD/iso above (i.e. using the
[Kayak Interactive Installer](KayakInteractive)).

Using Vagrant
-------------

[Vagrant](http://vagrantup.com) is a system for managing and provisioning virtual
machines with tools like [Chef](http://www.opscode.com/chef/), [Ansible](http://www.ansible.com/home),
and [Puppet](https://puppetlabs.com/). It's an easy way to try out an OmniOS system.

Unless otherwise noted, all baseboxes feature:

* 40 GB disk allocated as a single zpool
* Vagrant default insecure ssh keys, with password-less sudo
* omniti-ms publisher

To use OmniOS Vagrant baseboxes, we strongly recommend that you refer to
boxes we provide through the Atlas catalogue. Only the baseboxes
provided under the `omnios/` namespace are official. We use a standard
naming scheme for all of our baseboxes, which is simply the release
number or name. Thus, our current LTS release's basebox is named
`omnios/r151014` and the bloody release is `omnios/bloody`.

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

```
$ vagrant init omnios/r151014
$ vagrant up
```

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

OmniOS AMI names are of the form:

```
"OmniOS <release> <LTS/stable> <optional non-default setting> <AMI creation date: YYYYMMDD>"
```

We provide the AMI Names below. (Note that AMI IDs are specific to region.)

**Amazon Public AMIs for OmniOS**

| Region      | AMI Name                            |
|-------------|-------------------------------------|
| all regions | OmniOS r151006 LTS 20160520         |
| all regions | OmniOS r151014 LTS 20170427         |
| all regions | OmniOS r151014 LTS OpenSSH 20170427 |
| all regions | OmniOS r151020 Stable 20170427      |
| all regions | OmniOS r151022 LTS 20170515         |

From the network
----------------

The [Kayak](https://github.com/omniosorg/kayak) network
installer enables installation over a network utilizing PXE, DHCP and
HTTP. It is a replacement for Solaris Automated Installer (AI) that
delivers some new features:

* Support for mirrored rpool
* ZFS compression on by default for rpool
* Installation image delivered as ZFS dataset

Kayak comes with a working boot kernel and miniroot, but you will need
to create the installation image yourself.

### Set up a Kayak server

Install Kayak server and kernel files:

```
# pkg install system/install/kayak system/install/kayak-kernel service/network/tftp
```

**(r151014 and earlier)** Activate TFTP server by adding the following line to
`/etc/inetd.conf` and running the `inetconv` command.  This will create
an SMF service, `network/tftp/udp6`.  Note that “udp6” nevertheless serves
BOTH IPv4 and IPv6.

```
tftp    dgram   udp6    wait    root    /usr/sbin/in.tftpd      in.tftpd -s /tftpboot
```

**(r151016 and later)** Activate the TFTP server (note that “udp6” nevertheless serves BOTH IPv4 and IPv6):

```
# svcadm enable tftp/udp6:default
```

Activate the Kayak service. This provides an HTTP server which serves files
from `/var/kayak/kayak`.  Client installation logs will be uploaded to
`/var/kayak/logs`. Available installation images, client configs and logs
will be visible from the main index page.

```
# svcadm enable svc:network/kayak:default
```

Fetch the ZFS installation image. This is a ZFS root filesystem from a default
installation. During Kayak installation this is decompressed and received to
create the local root filesystem. Save the bzip file to `/var/kayak/kayak`. 
It should appear under “Available Images” on your server's index page.

[Current stable and LTS](http://omnios.omniti.com/media/r151022.zfs.bz2)

```
md5 (r151022.zfs.bz2) = c8aa7f911185989de7543685924c5ffa
sha1 (r151022.zfs.bz2) = 4437393c10be6a175af00ea74b737c6eaa6f4be0
sha256 (r151022.zfs.bz2) = b4a0198106398efe1140686eed2c45fa0c2fe18dc755b4aea34d03f1afeae2d1
```

[Bloody](http://omnios.omniti.com/media/r151023-20170515.zfs.bz2)

```
md5 (r151023-20170515.zfs.bz2) = f2ecee68ba5d6d85f1229eeca64f8a08
sha1 (r151023-20170515.zfs.bz2) = 27899d8d6be7a530387f5c312abad2ed76b0b89d
sha256 (r151023-20170515.zfs.bz2) = a13d325927fe703cd5a4b4c96e23410c2a2c3366df14c860abfb99d7325dc9f9
```

If this is not the same OS version as your kayak host, you may need to
update `/tftpboot/boot/grub/menu.lst` to include your new image.

**(OPTIONAL)** Create the installation image if you don't wish to use
the one provided. This requires a ZFS dataset to act as a container for
the image. The image will be placed in `/var/kayak/kayak` as
`<release>.zfs.bz2`. Note that because this step manipulates kernel
drivers as part of building the image, it must be run in the global zone.
If you want to use a non-global zone as your Kayak server, you can do
the build step on a global zone and copy the file to the Kayak server.

```
# zfs create rpool/kayak_image
# /usr/share/kayak
# gmake BUILDSEND=rpool/kayak_image install-web
```

Available, but not fully tested, is also the [illumos/BSD Loader](BSDLoader.md) for PXE boot.
With a little reorganization, you can also [serve multiple OS releases from one Kayak server](KayakMultiRelease.md).

TODO: show how to customize the installation image above and beyond the
“entire” incorporation.

### Set up a Kayak client config

Kayak client configs are snippets of bash script that get executed
during installation.

On your Kayak server, copy `/usr/share/kayak/sample/000000000000.sample` to
a file in `/var/kayak/kayak` with a name matching the hex values of the
client's MAC address in all caps, e.g. `010203ABCDEF`.

Edit this file as needed. See the [client documentation](KayakClientOptions.md)
for details on the possible settings.

### Install a client

Configure your DHCP server to direct the client to the Kayak server's
address and set the boot file to be “pxegrub”.

If you are using ISC DHCP, the entry for your host might look like:

```
host installz {
  filename "pxegrub";
  next-server 10.0.0.5;
  option host-name "installz";
  hardware ethernet 01:02:03:AB:CD:EF;
  fixed-address 10.0.0.100;
}
```

Where `next-server` is the IP of your Kayak server.

PXE-boot the client. To avoid an endless loop of installation, do not
make network the default boot device. Most server firmware allows a
certain keypress to modify the boot order temporarily, such as F11 or
F12.

The installer will attempt to bring up all available network interfaces
and will attempt DHCP configuration on all of them in parallel. If your
system is connected to multiple networks that contain DHCP servers, you
may get undesirable results.

If the installation succeeds, the client reboots unless `NO_REBOOT` is
set in the client config. If installation fails, you can get a shell
prompt by entering the username “root” and a blank password. Once you
have finished, either reset the system power or reboot with:

```
. /kayak/install_help.sh && Reboot
```

The usual 'reboot' command is non-functional in the miniroot environment.

### In A Non-OmniOS Environment

If you already have a PXE setup on another platform, you can set it up
to install OmniOS clients. See [PXEfromNonOmniOS](PXEfromNonOmniOS.md)
where Gavin Sandie shows how he set it up in a Debian environment.

Post-Install
------------

See the [GeneralAdministration Admin Guide](GeneralAdministration.md) for post-install
steps, and the MoreInfo page for links to external sources of additional
documentation.

If you used the ISO installer and want to set up a mirrored root pool,
see [Mirroring A Root Pool](GeneralAdministration.md#MirroringARootPool).
