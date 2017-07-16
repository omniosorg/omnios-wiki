Serving Multiple Releases From A Kayak Server
=============================================

You may want to support installation of clients to different releases in
your environment, such as enabling both LTS and current-stable. By
default, a Kayak setup only serves the release matching the version of
Kayak installed, but there is no technical restriction on what it can
serve.

Here's an example of how to modify your Kayak configs to support
multiple releases concurrently, from a single Kayak server. In this
example, the Kayak server is on an LTS release (r151006) but is serving
both r151006 and r151010 clients.

You can start either with the official Kayak packages, or do an install
from [source](https://github.com/omniosorg/kayak). If you do a source
install, make sure to check out and build the branch matching the
release of the build machine, to ensure you get the correct bits.

The files you will need from the non-native release(s) are the ZFS
image, which you can just download (see below), plus the boot kernel
(“unix”) and ramdisk root filesystem (“miniroot.gz”). There is a way to
[get these files without pkg(1)](FetchIPSFilesWithoutPkg.md) if you
don't have an installation of that version handy.

ZFS images
----------

These live in `/var/kayak/kayak` and the [downloadable images](Installation.md#SetupaKayakserver)
already have non-conflicting names, so just fetch
the ones you want to serve. Optionally, make a generic symlink to the
release image you want to serve, so that you don't have to keep editing
the GRUB config for each new weekly release.

```
lrwxrwxrwx 1   19 Jul 15 14:48 r151006.zfs.bz2 -> r151006_059.zfs.bz2
-rw-r--r-- 1 253M Apr  9 16:53 r151006_049.zfs.bz2
-rw-r--r-- 1 253M Jun 18 17:34 r151006_059.zfs.bz2
lrwxrwxrwx 1   16 Aug  6 16:40 r151010.zfs.bz2 -> r151010j.zfs.bz2
-rw-r--r-- 1 302M Jun  5 17:20 r151010j.zfs.bz2
```

Boot Kernel
-----------

The package puts the boot kernel in `/tftpboot/boot/platform/i86pc/kernel/amd64/`
but we need a release-specific path
so that our multiple copies don't conflict. This is just an example--
any non-conflicting path and/or filename combination will work.

Starting with our r151006 system, which has the kayak-kernel files
already installed in their default location:

```
cd /tftboot/boot
mkdir 006 010
mv platform 006/
mkdir -p 010/platform/i86pc/kernel/amd64
cp /path/to/unix.010 010/platform/i86pc/kernel/amd64/unix
```

You would end up with the boot kernels like so:

```
/tftpboot/boot/006/platform/i86pc/kernel/amd64/unix
/tftpboot/boot/010/platform/i86pc/kernel/amd64/unix
```

Miniroot
--------

Just like the boot kernel, the miniroots must match their release and be
in non-conflicting paths. By default, the native one is `/tftpboot/kayak/miniroot.gz`.

```
cd /tftpboot/kayak
mkdir 006 010
mv miniroot.gz 006/
cp /path/to/miniroot.gz.010 010/miniroot.gz
```

The result:

```
/tftpboot/kayak/006/miniroot.gz
/tftpboot/kayak/010/miniroot.gz
```

GRUB Config
-----------

Tying it all together, we make GRUB menu entries for each release. Edit
`/tftpboot/boot/grub/menu.lst` so that it looks something like:

```
default=0
timeout=10
min_mem64 1024

title OmniOS Kayak r151006
        kernel$ /boot/006/platform/i86pc/kernel/$ISADIR/unix -B install_media=http:///kayak/r151006.zfs.bz2,install_config=http:///kayak
        module$ /kayak/006/miniroot.gz

title OmniOS Kayak r151010
        kernel$ /boot/010/platform/i86pc/kernel/$ISADIR/unix -B install_media=http:///kayak/r151010.zfs.bz2,install_config=http:///kayak
        module$ /kayak/010/miniroot.gz
```

> Note: the default config sets the GRUB timeout to 1 second. You
> will likely want to increase this so the user has time to make a choice.

Now, when a client boots from the Kayak server, their GRUB menu will
offer both releases and the client can choose which one to install.
