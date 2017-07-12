PXE Install from non-OmniOS Setup
=================================

This is work by Gavin Sandie
([@gavinsandie](https://twitter.com/gavinsandie)) originally published
at <https://gist.github.com/3874066>

omnios pxe install notes
------------------------

The goal was to be able to perform a network install of OmniOS from a
Debian system.

I know there is refinement that can take place in this process (and
these notes), but this got me up and running.

All testing took place on a Mac running !VirtualBox with the extra
extensions installed to allow for PXE booting. However I cannot see why
this wouldn't work on real hardware in a network that is already setup
to do PXE installs.

I setup:

`* omnios vm running bloody release (20121004 release)`\
` - Solaris 10/x64 type vm`\
` - 512Mb RAM`\
` - 16Gb drive`\
` - choose Intel networking`\
` - OS installed using all defaults from the ISO`\
`* vm running debian`\
` - two nics`\
`   - choose Intel networking`\
`   - first was host-only networking`\
`   - second setup NAT`\
`* solaris 10/x64 blank vm`\
` - two nics`\
`   - choose Intel networking`\
`   - first was host-only networking, same network as debian vm, make a note of the MAC address`\
`   - second setup for NAT`\
` - blank 16Gb disk attached`\
` - set boot order to network boot first, but you can do this from the F12 menu`

### PXE setup

To perform the PXE boot you're going to need the initial kernel
environment and miniroot.

These are packaged in the “system/install/kayak-kernel” package.
Unfortunately as far as I could see there is no way to download these
packages using http, you can only get the manifest. I installed an
OmniOS vm so that I would have access to pkg(5).

Examples taken from \[wiki:PopulatingRepos\]

Now if you browse into pkgs you'll see the system/install/kayak-kernel
dir which contains the release. In there are the actual package files. I
used the manifest.file to match the checksummed filenames against what
they should actually be. You should end up with:

My VM had less than 4Gb of RAM and I ended up hitting a bug in the
disk\_help.sh script. If you've got more than 4Gb of RAM you can skip
this step. This has been fixed, but the fix wasn't in the miniroot I
had. Fortunately it's easy to patch:

and apply this patch:

<http://omnios.omniti.com/changeset.php/core/kayak/436e39c34bf354df2bd4a607856cb8047002db74>

Now copy the files onto your debian box.

You'll also need some install media. If you look at the menu.list file
you'll see that the kernel boots with an install\_media and
install\_config option:

The install\_config is your kayak config, which I'll cover below. The
install media is a compressed zfs image, which you can create with the
kayak tools.

I used the kayak source:

Now build the image:

This will download the packages and install them into a zfs mount. It
will then create a compressed snapshot using zfs and bzip.

When it's done you'll have , copy this to your debian box.

On the debian box you'll need to install a dhcp server, tftp server, and
a webserver. I went with:

I used the default config for the tftpd server, it uses /srv/tftp as its
root, you install the file copied from the OmniOS box at:

Setup your webserver to serve out the files from /srv/tftp. The
menu.list expects to get things from <http://IP/kayak> to make sure you
can access that. Edit the menu.list and change to be .

You'll need a basic kayak config. The wiki explains the config options:
\[wiki:KayakClientOptions\]

I used the example config:

it should be named after the MAC address of the card, and live in
/srv/tftp/kayak

e.g.

For the networking, I had eth0 using NAT/DHCP from virtualbox. eth0 was
on the host only network. I statically assigned it
10.1.0.10/255.255.255.0

I've then used the following simple DHCP config. Change the MAC to be
the MAC of your host only networking card from the solaris type vm.

Now you should be able to boot your solaris type vm. It will boot over
the network, launch grub, then proceed into the omnios installer. When
it finishes you can login as root with a blank password, shut down the
box, and disable the pxe booting. Then start the box back up, and login
(root and a blank password).

### Troubleshooting

If the install fails you'll get left in a miniroot environment. There is
a log in /tmp/kayak.log which should help figure out what's wrong. The
miniroot I used had no less, so you'll need to use head to view it. If
it gets as far as downloading the zfs image, then you'll have more tools
in /mnt that you can use.
