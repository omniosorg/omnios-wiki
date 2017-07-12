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
from [source](https://github.com/omniti-labs/kayak). If you do a source
install, make sure to check out and build the branch matching the
release of the build machine, to ensure you get the correct bits.

The files you will need from the non-native release(s) are the ZFS
image, which you can just download (see below), plus the boot kernel
(“unix”) and ramdisk root filesystem (“miniroot.gz”). There is a way to
\[wiki:FetchIPSFilesWithoutPkg get these files without pkg(1)\] if you
don't have an installation of that version handy.

ZFS images
----------

These live in and the \[wiki:Installation\#SetupaKayakserver
downloadable images\] already have non-conflicting names, so just fetch
the ones you want to serve. Optionally, make a generic symlink to the
release image you want to serve, so that you don't have to keep editing
the GRUB config for each new weekly release.

Boot Kernel
-----------

The package puts the boot kernel in but we need a release-specific path
so that our multiple copies don't conflict. This is just an example--
any non-conflicting path and/or filename combination will work.

Starting with our r151006 system, which has the kayak-kernel files
already installed in their default location:

You would end up with the boot kernels like so:

Miniroot
--------

Just like the boot kernel, the miniroots must match their release and be
in non-conflicting paths. By default, the native one is .

The result:

GRUB Config
-----------

Tying it all together, we make GRUB menu entries for each release. Edit
so that it looks something like:

&gt; Note: the default config sets the GRUB timeout to 1 second. You
will likely want to increase this so the user has time to make a choice.

Now, when a client boots from the Kayak server, their GRUB menu will
offer both releases and the client can choose which one to install.
