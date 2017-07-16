PXE Install from non-OmniOS Setup
=================================

This is work by Gavin Sandie
([@gavinsandie](https://twitter.com/gavinsandie)) originally published
at <https://gist.github.com/3874066>

## omnios pxe install notes

The goal was to be able to perform a network install of OmniOS from a
Debian system.

I know there is refinement that can take place in this process (and
these notes), but this got me up and running.

All testing took place on a Mac running !VirtualBox with the extra
extensions installed to allow for PXE booting. However I cannot see why
this wouldn't work on real hardware in a network that is already setup
to do PXE installs.

I setup:

* omnios vm running bloody release (20121004 release)
  * Solaris 10/x64 type vm
  * 512Mb RAM
  * 16Gb drive
  * choose Intel networking
  * OS installed using all defaults from the ISO
* vm running debian
  * two nics
    * choose Intel networking
    * first was host-only networking
    * second setup NAT
* solaris 10/x64 blank vm
  * two nics
     * choose Intel networking
     * first was host-only networking, same network as debian vm, make a note of the MAC address
     * second setup for NAT
  * blank 16Gb disk attached
  * set boot order to network boot first, but you can do this from the F12 menu

## PXE setup

To perform the PXE boot you're going to need the initial kernel
environment and miniroot.

These are packaged in the `system/install/kayak-kernel` package.
Unfortunately as far as I could see there is no way to download these
packages using http, you can only get the manifest. I installed an
OmniOS vm so that I would have access to pkg(5).

```
# mkdir pkgs
# pkgrecv -s https://pkg.omniti.com/omnios/bloody -d /root/pkgs --raw pkg:/system/install/kayak-kernel
```

Examples taken from [PopulatingRepos](PopulatingRepos.md)

Now if you browse into pkgs you'll see the system/install/kayak-kernel
dir which contains the release. In there are the actual package files. I
used the manifest.file to match the checksummed filenames against what
they should actually be. You should end up with:

```
pxegrub
miniroot.gz
unix
menu.lst
```

My VM had less than 4Gb of RAM and I ended up hitting a bug in the
disk\_help.sh script. If you've got more than 4Gb of RAM you can skip
this step. This has been fixed, but the fix wasn't in the miniroot I
had. Fortunately it's easy to patch:

```
# gzip -d miniroot.gz
# cp miniroot /tmp
# mkdir /mnt/test
# mount -o nologging `lofiadm -a /tmp/miniroot` /mnt/test/
# vi /mnt/test/kayak/disk_help.sh
```

and apply this patch: <http://omnios.omniti.com/changeset.php/core/kayak/436e39c34bf354df2bd4a607856cb8047002db74>

```
# umount /mnt/test
# lofiadm -d /tmp/miniroot
# cp /tmp/miniroot .
# gzip miniroot
```

Now copy the files onto your debian box.

You'll also need some install media. If you look at the `menu.list` file
you'll see that the kernel boots with an `install_media` and
`install_config` option:

```
install_media=http:///kayak/r151002.zfs.bz2,install_config=http:///kayak
```

The `install_config` is your kayak config, which I'll cover below. The
install media is a compressed zfs image, which you can create with the
kayak tools.

I used the kayak source:

```
# pkg install git
# mkdir src && cd src
# git clone https://github.com/omniosorg/kayak
# cd kayak
```

Now build the image:

```
# ./build_zfs_send.sh bloody
```

This will download the packages and install them into a zfs mount. It
will then create a compressed snapshot using zfs and bzip.

When it's done you'll have `/rpool/kayak_bloody.zfs.bz2`, copy this to your debian box.

On the debian box you'll need to install a dhcp server, tftp server, and
a webserver. I went with:

```
tftpd-hpa
isc-dhcp-server
nginx
```

I used the default config for the tftpd server, it uses /srv/tftp as its
root, you install the file copied from the OmniOS box at:

```
/srv/tftp/kayak/miniroot.gz
/srv/tftp/kayak/kayak_bloody.zfs.bz2
/srv/tftp/pxegrub
/srv/tftp/boot/grub/menu.lst
/srv/tftp/boot/platform/i86pc/kernel/amd64/unix
```

Setup your webserver to serve out the files from /srv/tftp. The
menu.list expects to get things from <http://IP/kayak> to make sure you
can access that. Edit the `menu.list` and change `r151002.zfs.bz2` to be `kayak_bloody.zfs.bz2`.

You'll need a basic kayak config. The wiki explains the config options:
[KayakClientOptions](KayakClientOptions.md)

I used the example config:

```
BuildRpool c1t0d0
SetHostname omnios-installer
UseDNS 8.8.8.8
Postboot '/sbin/ipadm create-if e1000g1' # Use g1 here as the first nic is host-only networking
Postboot '/sbin/ipadm create-addr -T dhcp e1000g1/v4'
NO_REBOOT=1
```

it should be named after the MAC address of the card, and live in
`/srv/tftp/kayak`

e.g.

```
/srv/tftp/kayak/0800278C5336
```

For the networking, I had eth0 using NAT/DHCP from virtualbox. eth0 was
on the host only network. I statically assigned it
10.1.0.10/255.255.255.0

I've then used the following simple DHCP config. Change the MAC to be
the MAC of your host only networking card from the solaris type vm.

```
    default-lease-time 600;
    max-lease-time 7200;
    
    allow booting;
    allow bootp;
    
    subnet 10.1.0.0 netmask 255.255.255.0 {
      range 10.1.0.50 10.1.0.100;
      option broadcast-address 10.1.0.255;
      option routers 10.1.0.10;
      option domain-name-servers 10.1.0.10;
    }
    
    group {
    
      next-server 10.1.0.10;
      host tftpclient {
        hardware ethernet MAC;
        filename "pxegrub";
      }
    }
```

Now you should be able to boot your solaris type vm. It will boot over
the network, launch grub, then proceed into the omnios installer. When
it finishes you can login as root with a blank password, shut down the
box, and disable the pxe booting. Then start the box back up, and login
(root and a blank password).

### Troubleshooting

If the install fails you'll get left in a miniroot environment. There is
a log in `/tmp/kayak.log` which should help figure out what's wrong. The
miniroot I used had no less, so you'll need to use head to view it. If
it gets as far as downloading the zfs image, then you'll have more tools
in `/mnt` that you can use.
