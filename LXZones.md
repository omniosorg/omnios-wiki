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

```
# pkg install pkg:/system/zones/brand/lx
```

The next thing one needs is an *image*. An image is either a:

* ZFS Send Stream (plain or gzipped)
* A dataset or snapshot residing on the same pool as the LX zone's zonepath
* A tar file (plain or gzipped)

The image must contain a Linux userland. For example, CentOS 6.8, or
Ubuntu 16.04.

These can be found at various places. The bottom entries of the
[Joyent image list](https://images.joyent.com/images) are the most recent.
Search for “Container-native”.

For example:

```
{
    "v": 2,
    "uuid": "0be607d2-8b61-11e6-bf98-03750d422a79",
    "owner": "00000000-0000-0000-0000-000000000000",
    "name": "centos-6",
    "version": "20161006",
    "state": "active",
    "disabled": false,
    "public": true,
    "published_at": "2016-10-06T01:06:00Z",
    "type": "lx-dataset",
    "os": "linux",
    "files": [
      {
        "sha1": "d1b52f3382fa2f51bb95ba0e7760447c32deba82",
        "size": 286693599,
        "compression": "gzip"
      }
    ],
    "description": "Container-native CentOS 6.8 64-bit image. Built to run on containers with bare metal speed, while offering all the services of a typical unix host.",
    "homepage": "https://docs.joyent.com/images/container-native-linux",
    "requirements": {
      "networks": [
        {
          "name": "net0",
          "description": "public"
        }
      ],
      "min_platform": {
        "7.0": "20160317T000105Z"
      },
      "brand": "lx"
    },
    "tags": {
      "role": "os",
      "kernel_version": "2.6.32"
    }
  },
```

Pay attention to both the image UUID, and the ```kernel_version attribute```. The compressed
ZFS send stream for this Joyent image can be obtained knowing the image
UUID, like so [file](https://images.joyent.com/images/0be607d2-8b61-11e6-bf98-03750d422a79/file).

Here's a terminal session transcript:

```
bloody(/tmp)[0]% curl -o centos68.zss.gz https://images.joyent.com/images/0be607d2-8b61-11e6-bf98-03750d422a79/file
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  273M  100  273M    0     0  8584k      0  0:00:32  0:00:32 --:--:-- 9296k
bloody(/tmp)[0]% file centos68.zss.gz
centos68.zss.gz:        gzip compressed data - deflate method , max compression
bloody(/tmp)[0]% gunzip centos68.zss.gz 
bloody(/tmp)[0]% file centos68.zss
centos68.zss:   ZFS snapshot stream
bloody(/tmp)[0]% 
```

To turn this into a working LX zone, you must next properly configure
the zone using zonecfg(1M). Remember the above was 2.6.32:

```
# zonecfg -z lx0
zonecfg:lx0> create
zonecfg:lx0> set zonepath=/zones/lx0
zonecfg:lx0> set brand=lx
zonecfg:lx0> set autoboot=false
zonecfg:lx0> set ip-type=exclusive
zonecfg:lx0> add net
zonecfg:lx0> set physical=lx0
zonecfg:lx0> add property (name=gateway,value="192.168.0.1")
zonecfg:lx0> add property (name=ips,value="192.168.0.69/24")
zonecfg:lx0> add property (name=primary,value="true")
zonecfg:lx0> end
zonecfg:lx0> add attr
zonecfg:lx0> set name=dns-domain
zonecfg:lx0> set type=string
zonecfg:lx0> set value=example.com
zonecfg:lx0> end
zonecfg:lx0> add attr
zonecfg:lx0> set name=resolvers
zonecfg:lx0> set type=string
zonecfg:lx0> set value=192.168.0.1
zonecfg:lx0> end
zonecfg:lx0> add attr
zonecfg:lx0> set name=kernel-version
zonecfg:lx0> set type=string
zonecfg:lx0> set value=2.6.32
zonecfg:lx0> end
zonecfg:lx0> set max-lwps=2000
zonecfg:lx0> exit
#
```

You will notice that for LX zones, we must use zonecfg(1M) to configure
its networking. Using zonecfg(1M) for networking configuration only is
supported on LX zones. Also note the explicit cap on max-lwps. This
feeds into the LX emulation of ulimit(1), otherwise some Linux binaries
break.

Once an LX zone is configured, one must use zoneadm(1M) to install the
zone, using one of the image sources (-t for tarballs, -s for ZFS
streams, snapshots, or datasets).

To use a ZFS send stream (or gzipped ZFS send stream):

```
# zoneadm -z lx0 install -s /full/path/to/centos68.zss.gz
```

To use a ZFS dataset:

```
# zoneadm -z lx0 install -s name/of/zfs-dataset
```

A snapshot will be made, cloned, and promoted. The dataset MUST be on
the same pool as the zonepath.

To use a ZFS snapshot:

```
# zoneadm -z lx0 install -s name/of/datasets@snapshot
```

The snapshot will become the dataset for the LX zone. The snapshot MUST
be on the same pool as the zonepath.

To use a tarball (like a docker one):

```
# zoneadm -z lx0 install -t /full/path/to/docker-tarball.tgz
```

Afterwards, you boot the zone like any other one.

LX Zones, BEs, and Upgrades
---------------------------

LX Zones, unlike ipkg or lipkg zones, do not have individual boot
environments. If you update and create a new BE, any LX zones are not
explicitly updated. LX zones use lofs mounts to remap the global zone's
```/usr/bin``` into ```/native/usr/bin``` inside the LX zone. The zone's
contents stay constant no matter which BE you're using.

Keeping up
----------

We will be tracking Joyent's developments of LX Zones closely, and the
new
[README.OmniOS](https://github.com/omniosorg/illumos-omnios/blob/r151022/README.OmniOS)
will keep you up to date on what illumos-joyent:master commit we last
synched with. Each release has its own target as well:

* [`r151022`](https://github.com/omniosorg/illumos-omnios/blob/r151022/README.OmniOS)
* [`bloody`](https://github.com/omniosorg/illumos-omnios/blob/master/README.OmniOS)

See the [How we side-port LX](Maintainers.md#Cherrypickingfromillumos-joyent) page for
gory details.

Possible Futures
----------------

The LX brand work has yielded some interesting insights, as has
community feedback from r151020. Some insights may turn into other
related features. Examples of potential (but not promised) ideas
include:

* Using more /native tools to configure networking in an LX zone
* Using zonecfg(1M) for networking configuration insides OmniOS Zones (ipkg, lipkg, lofs-native per above)
* BE-aware LX zones
* A native OmniOS zone that uses lofs for its ```/usr``` filesystem, like LX does for ```/native```
