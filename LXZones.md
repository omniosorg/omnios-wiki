LX Branded Zones
================

Hello, Linux!
-------------

The LX branded zone is a new type of zone, resurrected and further
developed by Joyent for SmartOS, and now ported over to OmniOS. It
allows an OmniOS deployment to host and run most Linux applications in a
lighter-weight-than-a-VM environment.

Getting Started
---------------

The LX Brand support is not included with an initial install. One must
explicitly install LX Brand support:

The next thing one needs is an *image*. An image is either a:

-   ZFS Send Stream (plain or gzipped)

<!-- -->

-   A dataset or snapshot residing on the same pool as the LX zone's
    zonepath.

<!-- -->

-   A tar file (plain or gzipped).

The image must contain a Linux userland. For example, CentOS 6.8, or
Ubuntu 16.04.

These can be found at various places. The bottom entries of the [Joyent
image list](https://images.joyent.com/images) are the most recent.
Search for “Container-native”.

For example:

Pay attention to both the image UUID, and the attribute. The compressed
ZFS send stream for this Joyent image can be obtained knowing the image
UUID, like so:
[1](https://images.joyent.com/images/0be607d2-8b61-11e6-bf98-03750d422a79/file).
Here's a terminal session transcript:

To turn this into a working LX zone, you must next properly configure
the zone using zonecfg(1M). Remember the above was 2.6.32:

You will notice that for LX zones, we must use zonecfg(1M) to configure
its networking. Using zonecfg(1M) for networking configuration only is
supported on LX zones. Also note the explicit cap on max-lwps. This
feeds into the LX emulation of ulimit(1), otherwise some Linux binaries
break.

Once an LX zone is configured, one must use zoneadm(1M) to install the
zone, using one of the image sources (-t for tarballs, -s for ZFS
streams, snapshots, or datasets).

To use a ZFS send stream (or gzipped ZFS send stream):

To use a ZFS dataset:

A snapshot will be made, cloned, and promoted. The dataset MUST be on
the same pool as the zonepath.

To use a ZFS snapshot:

The snapshot will become the dataset for the LX zone. The snapshot MUST
be on the same pool as the zonepath.

To use a tarball (like a docker one):

Afterwards, you boot the zone like any other one.

LX Zones, BEs, and Upgrades
---------------------------

LX Zones, unlike ipkg or lipkg zones, do not have individual boot
environments. If you update and create a new BE, any LX zones are not
explicitly updated. LX zones use lofs mounts to remap the global zone's
into inside the LX zone. The zone's contents stay constant no matter
which BE you're using.

Keeping up
----------

We will be tracking Joyent's developments of LX Zones closely, and the
new
[README.OmniOS](https://github.com/omniti-labs/illumos-omnios/blob/master/README.OmniOS)
will keep you up to date on what illumos-joyent:master commit we last
synched with. Each release has its own target as well:

`* `[`r151022`](https://github.com/omniti-labs/illumos-omnios/blob/r151020/README.OmniOS)

`* `[`bloody`](https://github.com/omniti-labs/illumos-omnios/blob/master/README.OmniOS)

See the \[wiki:Maintainers\#Cherrypickingfromillumos-joyent How we
side-port LX\] page for gory details.

Possible Futures
----------------

The LX brand work has yielded some interesting insights, as has
community feedback from r151020. Some insights may turn into other
related features. Examples of potential (but not promised) ideas
include:

`* Using more /native tools to configure networking in an LX zone.`

`* Using zonecfg(1M) for networking configuration insides OmniOS Zones (ipkg, lipkg, lofs-native per above).`

`* BE-aware LX zones.`

`* A native OmniOS zone that uses lofs for its `` filesystem, like LX does for ``.`
