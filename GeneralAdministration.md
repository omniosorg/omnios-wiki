General Administration Guide
============================

Networking
----------

[dladm(1M)](http://illumos.org/man/1m/dladm)

[ipadm(1M)](http://illumos.org/man/1m/ipadm)

[route(1M)](http://illumos.org/man/1m/route)

### Setting up dynamic (DHCP) networking

First identify the physical interface on which you would like
networking:

```
# dladm show-phys
LINK         MEDIA                STATE      SPEED  DUPLEX    DEVICE
e1000g0      Ethernet             unknown    0      half      e1000g0
e1000g1      Ethernet             ?          1000   full      e1000g1
```

Physical interfaces that don't have a corresponding IP interface might
not show their state correctly (in this case e1000g0).

To create an IP interface, then create an address and set it to DHCP:

```
# ipadm create-if e1000g0
# ipadm create-addr -T dhcp e1000g0/v4
# ipadm show-addr
ADDROBJ           TYPE     STATE        ADDR
lo0/v4            static   ok           127.0.0.1/8
e1000g0/v4        dhcp     ok           10.0.2.15/24
lo0/v6            static   ok           ::1/128
```

### Setting up static networking

Just as above, we need to create an interface (if it hasn't been created
already)

```
# ipadm create-if e1000g0
# ipadm create-addr -T static -a 192.168.1.10/24 e1000g0/v4static
# ipadm show-addr
ADDROBJ           TYPE     STATE        ADDR
lo0/v4            static   ok           127.0.0.1/8
e1000g0/v4static  static   ok           192.168.1.10/24
lo0/v6            static   ok           ::1/128
```

Now to setup a default route of 192.168.1.1:

```
# route -p add default 192.168.1.1
# netstat -rn -finet

Routing Table: IPv4
  Destination           Gateway           Flags  Ref     Use     Interface 
-------------------- -------------------- ----- ----- ---------- --------- 
default              192.168.1.1          UG        1          0 e1000g0     
192.168.1.0          192.168.1.10         U         3        349 e1000g0     
127.0.0.1            127.0.0.1            UH        2        164 lo0       
```

Finally, set up DNS resolution. Put your nameserver into
/etc/resolv.conf and configure NSS to read DNS from that file.

```
# echo 'nameserver 192.168.1.1' >> /etc/resolv.conf
# cp /etc/nsswitch.conf{,.bak}
# cp /etc/nsswitch.{dns,conf}
```

### Creating Additional Addresses

There's nothing special about the “v4” or “v4static” address names; it's
just a convention. You can create additional interfaces with whatever
names you want.

```
# ipadm create-addr -T static -a 192.168.1.11/24 e1000g0/myfancyaddr
```

If you want to set up a temporary IP address (that won't be restored
after boot), use -t instead of -T:

```
# ipadm create-addr -t static -a 192.168.1.11/24 e1000g0/myfancyonetimeaddr
```

Users
-----

### Adding local users

* [useradd(1M)](http://illumos.org/man/1m/useradd)
* [automount(1M)](http://illumos.org/man/1m/automount)
* [automountd(1M)](http://illumos.org/man/1m/automountd)

On OmniOS, is [under automounter
control](http://www.c0t0d0s0.org/archives/4120-Less-known-Solaris-Features-exporthome-home-autofs.html),
so the directory is not writable.

The minimum configuration required for automounted ```/home``` to work is to
append the following line to ```/etc/auto_home```: 

```
*       localhost:/export/home/&
```

and reload the autofs service: ```svcadm refresh autofs```

A short-and-sweet useradd(1M) invocation on a fresh OmniOS installation
(which has /export/home as a ZFS dataset) would be: 

```
# useradd -b /export/home username
```
   
which would add a user with ```HOME=/export/home/username```. A reload of autofs
after that would have the user's home directory in ```/export/home``` AND ```/home```.

More sophisticated configurations are possible. For example, OmniTI's
[auto\_home.sh](http://labs.omniti.com/labs/tools/browser/trunk/auto_home.sh?format=txt)
script turns into a script that will create home directories on demand
(i.e. on a user's first login). If you create a ZFS dataset mounted at ,
the script will instead create a new ZFS dataset for each user.

### Configuring LDAP

TODO

Service Management
------------------

[SMF](http://illumos.org/man/5/smf)

If you've done any system administration on Linux or BSD, you're
probably familiar with a couple of different methods for starting
services. Linux uses the SysV init script system (/etc/init.d) while BSD
uses rc (resource control) which reads from a master config file,
rc.conf. In both cases, services are started with the desired arguments
at boot time (or on administrator command) and that's it. It's “fire and
forget”. If those processes die for some reason, the system has no way
to detect that condition and take action, so the administrator must
monitor for that condition and possibly even automate the recovery of
broken services.

Modern systems also run many more services than when init and rc were
conceived. Services are often dependent upon one another; they may
require that configuration files or particular resources such as
networking be available when they are started. Traditional init systems
offer only coarse control over service dependencies (start THIS before
THAT) and no recourse if things don't succeed. For instance, if
networking doesn't start because of an error, the system will still
happily try to start Apache, which will fail when it can't bind port 80.

Solaris traditionally used SysV init scripts. Solaris 10 introduced the
Service Management Facility, or SMF, as a replacement for init scripts.
SMF provides a model for services as objects that can be viewed,
controlled and configured, as well as handling dependencies, restarting
failed services, and enabling the system to boot faster by starting
independent services in parallel. illumos (and OmniOS by extension) also
uses SMF.

Three commands are used to manipulate services:

* [svcs(1)](http://illumos.org/man/1/svcs) for viewing status
* [svcadm(1M)](http://illumos.org/man/1m/svcadm) for starting ('enable'), stopping ('disable'), and repairing ('clear')
* [svccfg(1M)](http://illumos.org/man/1m/svccfg) for adding ('import'), configuring ('export' + interactive) and removing ('delete')

SMF objects are named using a URI format called FMRI (Fault Managed
Resource Identifier), which looks like:

```
svc:/network/http:apache22
```

When controlling this service, you can refer to the fully-qualified FMRI
or a substring that is unique, e.g.,

```
# svcadm disable -t apache22
```

### Manifests

[smf\_template(5)](http://illumos.org/man/5/smf_template)

Services are defined in an XML document called a *manifest* and loaded
into the system using ```svccfg```. This is usually a one-time process,
unless a change to the start/stop method or some other parameter
requires an update. You can view an existing service's manifest with
```svccfg export <FMRI>```, which writes to stdout. There are also
examples of [additional community-created
manifests](http://www.scalingbits.com/solaris/smf/directory).

If you are making a manifest from scratch for a service, there is an
easy to use tool called [manifold](http://code.google.com/p/manifold/)
that will ask you some simple questions and create a manifest. If you
have python installed, it's simply a case of running ```sudo
easy\_install Manifold``` to install the tool, and then ```manifold
<filename.xml>``` to create the manifest.

Additionally, Joyent's Max Bruning reviews the basics: [Documentation
for SMF](http://joyent.com/blog/documentation-for-smf)

If you need to set environment variables or run something as a
particular user, you can specify those things as “method contexts”.

```
<method_context>
  <method_environment>
    <envvar name='LD_PRELOAD' value='foo bar' />
  </method_environment>
</method_context>

<method_context>
  <method_credential user='nobody' group='nobody' />
</method_context>
```

You can specify them within a particular <exec_method> to affect only
that method (such as “start”) or before any exec\_method to apply to all
methods.

### Starting/Stopping services

```
# svcadm enable <FMRI>
# svcadm disable <FMRI>
```

The above invocations will persist across reboots. To temporarily enable
or disable, give the **-t** option to the subcommand.

If you are scripting or otherwise automating the enabling or disabling
of services and need to wait until the service is actually online (or
disabled), you may use the **-s** option to svcadm enable/disable. This
will force the command to not return until the service has finished
transitioning to the desired state.

### Listing Services

To see all running services, run **svcs** with no arguments:

```
$ svcs
...
online         Sep_14   svc:/system/name-service-cache:default
online         Sep_14   svc:/network/ldap/client:default
online         17:21:29 svc:/network/http:apache22
```

To see details about the service, get a long listing:

```
$ svcs -l apache22
fmri         svc:/network/http:apache22
name         Apache HTTP Server
enabled      true
state        online
next_state   none
state_time   Thu May 10 17:21:29 2012
logfile      /var/svc/log/network-http:apache22.log
restarter    svc:/system/svc/restarter:default
contract_id  1380929
dependency   require_all/error svc:/network/loopback:default (online)
dependency   optional_all/error svc:/network/physical:default (online)
dependency   require_all/error svc:/system/filesystem/local:default (online)
dependency   require_all/none file://localhost/www/conf/httpd.conf (online)
```

We can see that this service requires some networking, it requires the
local filesystem to be available, and it requires an httpd.conf file. If
the service cannot start due to a missing dependency, you can see which
one with this listing. The log file will contain any output generated by
the start/stop methods, so this is your primary source of debugging info
when troubleshooting the service.

#### Contracts

Most of the services you will see are *contract services*. These are
processes that run forever once started to provide a service (like
standard system daemons.) SMF tracks all processes started under a
particular contract, and if all of a contract's processes exit, this is
considered an error and will trigger an automatic restart. This is
almost always a good thing, but for Apache we must modify this behavior.
The master Apache process performs its own management on child
processes, starting and stopping them as needed to maintain configured
min/max server levels and restarting children that crash. However, SMF
is also watching the Apache children, and if it sees a child crash, it
will restart the entire service. Therefore we must tell SMF to ignore
process crashes because Apache will clean up on its own. We do this with
a property group within the particular instance (such as “apache22”):

```
      <property_group name='startd' type='framework'>
        <propval name='ignore_error' type='astring' value='core,signal'/>
      </property_group>
```

If the master Apache process crashes, all processes in the service will
be gone, and that will still trigger a restart of the service. If a
child crashes, SMF will do nothing and Apache will handle it.

**Find Contract ID Of A Process**

The contract ID is the key to putting everything together. It can be
used to work back from a known process ID to find the service FMRI that
started it.

Find out the contract ID (CTID) of a known service:

```
$ svcs -v apache22
STATE          NSTATE        STIME    CTID   FMRI
online         -             Jul_28       67 svc:/network/http:apache22
```

Find out the CTID of a known process ID:

```
$ ps -octid -p 915
 CTID
   67
```

So, working backward from the process to discover the service name:

```
$ svcs -o ctid,fmri -a | grep 67
    67 svc:/network/http:apache22
```

**Listing All Processes Related To A Service**

Find a list of processes connected to a known service:

```
$ svcs -p apache22
STATE          STIME    FMRI
online         Jul_28   svc:/network/http:apache22
               Jul_28        915 httpd
               11:59:47    12887 httpd
               13:10:13    14095 httpd
               13:59:47    14973 httpd
               14:07:07    15108 httpd
               14:10:13    15169 httpd
               14:10:14    15170 httpd
               14:11:59    15188 httpd
               14:59:47    16053 httpd
               15:07:07    16217 httpd
               15:10:13    16273 httpd
```

**Script-friendly Output**

Print a service's PIDs in a parseable format by using its contract ID:

```
$ pgrep -c 67
915
14095
12887
15188
14973
16273
16301
15170
15108
16053
16217
```

### Debugging offline/in-maintenance services

When a service fails repeatedly to start, SMF places the service in
“maintenance mode”. This means SMF has given up trying to restart the
service and is waiting for administrator intervention. Check the
service's log file for clues. When you've addressed the problem, run
```svcadm clear <FMRI>```. To see a list of all services that are not in
their desired state, run ```svcs -vx```

```
$ svcs -vx
svc:/network/http:apache22 (Apache HTTP Server)
 State: offline since Thu Jan 14 17:20:02 2010
Reason: Dependency file://localhost/www/conf/httpd.conf is absent.
   See: http://sun.com/msg/SMF-8000-E2
   See: man -M /usr/apache2/man -s 8 httpd
   See: man -M /usr/share/man -s 1M apache
   See: /var/svc/log/network-http:apache22.log
Impact: This service is not running.
```

This service cannot start because of a missing dependency.

A handy way to review the service's log:

```
$ tail $(svcs -L apache22)
```

The -L option prints the full path to the svc log.

Multiple Consoles
-----------------

(Thanks to Mayuresh Kathe and Volker Brandt for this section.)

You can enable multiple virtual consoles on OmniOS (this is handy for
development VMs). They are not enabled by default, but SMF is used to
bring them up. The following command will bring it up:

```
# svcs console-login
# svcadm enable vtdaemon
# svcadm enable console-login:vt2
# svcadm enable console-login:vt3
# svcadm enable console-login:vt4
# svcadm enable console-login:vt5
# svcadm enable console-login:vt6
        <enable more if need be>
# svcs console-login vtdaemon
# svccfg -s vtdaemon setprop options/hotkeys=true
# svccfg -s vtdaemon setprop options/secure=false
# svcadm refresh vtdaemon
# svcadm restart vtdaemon
# svcprop vtdaemon | grep hotkeys
# svcprop vtdaemon | grep secure
```

Once up, ALT (left or right) + Fkey (F1-F12) will switch to one of the
other virtual consoles. See the [vt(7I)](http://illumos.org/man/7I/vt)
man page for more details.

ZFS
---

* [zpool(1M)](http://illumos.org/man/1m/zpool)
* [zfs(1M)](http://illumos.org/man/1m/zfs)

[ZFS](http://wiki.illumos.org/display/illumos/ZFS) is a revolutionary
storage subsystem. It incorporates a number of advanced features not
found in other open source storage systems:

* Pooled storage: filesystems are not bound to a physical disk partition, so creating a new filesystem takes one command and less than 1 second to complete
* Copy-on-write, transactional updates: always consistent on disk (no fsck)
* End-to-end, provable data integrity: all data is checksummed when created and verified on every read to detect and heal silent data corruption
* Instantaneous snapshots and clones, portable streams: snapshots are quick to create, consume virtually no additional space until changes are made, and can be sent from one machine to another, even to different CPU architectures (adaptive endianness)
* Built-in compression, deduplication, NFS/CIFS/iSCSI sharing
* Simple administrative model (2 commands: zpool, zfs)

ZFS combines the features of a hardware RAID controller, a volume
manager, and a filesystem. The storage pool is divided into *datasets*,
of which there are several types:

**Filesystem**

A POSIX-compliant dataset that contains files, directories, etc.

**Volume**

Dataset accessible as a block device (```/dev/zvol/{dsk,rdsk}```), also known as a **zvol**.

**Snapshot** 

Represents a read-only, point-in-time view of a filesystem or volume.

**Clone**

A writeable copy of a snapshot. Unmodified data blocks refer to the parent snapshot.

Regardless of type, all datasets are named in a hierarchy of arbitrary
depth, rooted in the “pool dataset”, which has the same name as the pool
itself.

```
data
data/code
data/code/omnios-151007
data/pkgtest
```

Filesystems may be used locally or shared via NFS or CIFS, while zvols
can be shared as iSCSI targets or used locally as swap devices or to
host other filesystems such as UFS.

ZFS datasets have properties that give information about the dataset or
affect its behavior. Settable properties are inherited by descendant
datasets (also called “children”) and may be overridden at any level.
Common settable properties include mountpoint, recordsize, compression,
atime, quota. Common informational properties include creation time,
space used, available space, compression ratio.

### Common ZFS Commands

| Command                                                        | Description                                                                                                                                                                                                                   |
|----------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ```zfs list [<dataset>]```                                     | shows information about the specified dataset, or all datasets if no argument is given. The default is to show only filesystems and volumes. Use ```zfs list -t snapshot``` to show snapshots (or '-t all' to show all types) |
| ```zfs create <dataset>```                                     | Create a filesystem                                                                                                                                                                                                           |
| ```zfs create -V 20G <dataset>```                              | Create a zvol 20 gigabytes in size                                                                                                                                                                                            |
| ```zfs snapshot <dataset>@<NAME>```                            | Create a snapshot with name <NAME>                                                                                                                                                                                            |
| ```zfs rollback <dataset>@<snapshot>```                        | Restore a filesystem to the state referenced by <snapshot>. '''Use with caution!''' There is no confirmation and it happens immediately. This could have negative consequences for running applications                       |
| ```zfs destroy [<dataset>[@<snapshot>]]```                     | Delete a dataset. With no arguments it will error out if there are dependent datasets, such as snapshots and/or children. A list of dependent datasets will be printed                                                        |
| ```zfs [get <property> \| set <property>=<value>] <dataset>``` | Manipulate dataset properties. View the list of properties with ```zfs get all <filesystem>```'                                                                                                                               |

### Mirroring A Root Pool

If, after installing the boot pool on a single device, you later want to
make it a mirror, follow these steps, which you can do without
rebooting.

Root pools require SMI-labeled disks, and will not work with EFI-labeled
ones. The device you are adding must be at least as large as the
existing device in the pool. If it is larger, only the amount of space
equal to the size of the smallest disk will be usable by ZFS.

In this example we will assume the existing pool disk is “c0t0d0” and
the new device is “c0t1d0” (use
[format(1M)](http://illumos.org/man/1m/format) to see what devices are
available.) The following commands all require root privilege.

* Create a Solaris fdisk partition on 100% of the new disk. Here, “p0” refers to the entire disk starting after the MBR: ```# fdisk -B c0t1d0p0```
* Copy the disklabel from the existing device to the new one: ```# prtvtoc /dev/rdsk/c0t0d0s2 | fmthard -s - /dev/rdsk/c0t1d0s2```
* Attach the new device to the pool: ```# zpool attach -f rpool c0t0d0s0 c0t1d0s0```
* This will trigger a resilver operation, copying the ZFS data from the first device to the second, creating a mirror in the process. View the progress with ```zpool status rpool```
* Once the resilver is complete, make the new disk bootable: ```# installgrub /boot/grub/stage1 /boot/grub/stage2 /dev/rdsk/c0t1d0s0```

The next time you reboot the system, make sure to add the new disk as an
additional boot device!

Creating Zones
--------------

[Zones](http://www.solarisinternals.com/wiki/index.php/Zones), a.k.a.
Containers, are a lightweight virtualization technology, similar in
concept to BSD jails or OpenVZ in Linux. Note that while the link above
mentions sparse zones, currently OmniOS only supports whole-root zones.

Zones partition an OS instance into isolated application environments on
the same physical machine. Each zone looks, from within, like a separate
machine, but there is only one kernel. The primary OS instance is itself
a zone, a special case called the “global zone”. There is only one
global zone and it can administer all other non-global zones.

Start with the man pages of [zones(5)](http://illumos.org/man/5/zones),
[zonecfg(1M)](http://illumos.org/man/1m/zonecfg), and
[zoneadm(1M)](http://illumos.org/man/1m/zoneadm)

A typical zone configuration sequence. This is an exclusive-IP-stack
zone that uses a VNIC (myzone0) created with
[dladm(1M)](http://illumos.org/man/1m/dladm) on the global zone. Refer
to [zonecfg(1M)](http://illumos.org/man/1m/zonecfg) for details on
exclusive vs. shared IP stacks. Exclusive-stack allows the zone to
operate on different networks from the global zone, potentially even a
different VLAN.

```
# dladm create-vnic -l e1000g0 myzone0
# /usr/sbin/zonecfg -z myzone 
myzone: No such zone configured
Use 'create' to begin configuring a new zone.
zonecfg:myzone>
zonecfg:myzone> create
zonecfg:myzone> set zonepath=/zones/myzone
zonecfg:myzone> set autoboot=true
zonecfg:myzone> set limitpriv=default,dtrace_proc,dtrace_user
zonecfg:myzone> set ip-type=exclusive
zonecfg:myzone> add net
zonecfg:myzone:net> set physical=myzone0
zonecfg:myzone:net> end
zonecfg:myzone> verify
zonecfg:myzone> commit
zonecfg:myzone> exit
#
# zoneadm -z myzone install
# zoneadm -z myzone boot
```

These commands may also be placed in a file and read in by zonecfg:

```
# /usr/sbin/zonecfg -z myzone -f /path/to/myzone-cfg-file
```

There are many options to configuring zones. Review the documentation
for more info.

Once the zone boots,```zlogin -C myzone``` puts you on the zone's system console (as if you
were on a physical machine's serial console.) Use ```~.``` to exit the
console (don't forget additional ```~```'s if you are logged in via ssh.)
There usually isn't anything you need to do on the console. New zones
are like the initial OS install from the ISO-- you need to provide
post-install configuration. ```zlogin myzone``` (without the -C) will get you a shell in the
zone without the need to log in.

Creating Virtual Machines
-------------------------

See [Virtual Machines with KVM](VirtualMachinesKVM.md) for Details.

Package Management
------------------

OmniOS uses the [Image Packaging
System](http://en.wikipedia.org/wiki/Image_Packaging_System) (IPS)

Packages are distributed by “publishers” which are named entities that
publish packages. Publisher names must be unique within a given system.
By convention, publisher names are either product names (“omnios”) or a
DNS-like domain name (“ms.omniti.com”). Publishers may use multiple URLs
to provide a given set of packages. For example,
<http://pkg.omniti.com/omnios/release> and
<http://pkg.omniti.com/omnios/bloody> are both URLs for the “omnios”
publisher, each providing a subset of the total packages that make up
OmniOS (release versions vs. unstable versions.)

You can browse available packages in repositories that are available via
HTTP (as opposed to file-based repos). Hit the main repo URL and choose
“Packages” to see the list.

Unlike package formats such as SVR4, RPM or DEB, there is no on-disk
format for IPS packages. Repositories contain individual files and
manifests containing metadata that describe packages. Each file listed
in a manifest is downloaded and installed to the location described by
the “path” attribute in the manifest. When a package is updated, the
local and remote manifests are compared to determine which files differ
and only the new or changed files are downloaded. Files are also stored
gzipped in the repository to save additional bandwidth.

This also means that file assets are basically cache-able indefinitely,
as each file's content is hashed and its URI guaranteed not to change.

### FMRI Format

Package names are FMRIs (Fault Management Resource Identifiers) in the
```pkg://``` scheme and form a hierarchical namespace by type, determined
by the package author.  

```pkg://omnios/developer/build/gnu-make@3.82,5.11-0.151006:20130506T182730Z```

|----------------|--------------------------------------|
| Scheme         | pkg                                  |
| Publisher      | omnios                               |
| Category       | developer/build                      |
| Name           | gnu-make                             |
| Version String | 3.82,5.11-0.151006:20130506T182730Z  |

The version string has four parts, separated by punctuation:

|------------|------------------|-----------------------------------------------------------------------------------------------------------------|
| Component  | 3.82             | generally this is the upstream version                                                                          |
| Build      | 5.11             | the OS release, typically always 5.11 for modern illumos                                                        |
| Branch     | 0.151006         | distribution-specific version, which on OmniOS indicates the OmniOS release for which the package was built     |
| Timestamp  | 20130506T182730Z | an [ISO 8601](http://www.cl.cam.ac.uk/~mgk25/iso-time.html) timestamp indicating when the package was published |

A package name may be specified by a shorter string, provided it is
unambiguous, e.g. ```gnu-make``` or ```build/gnu-make``` instead of
```developer/build/gnu-make```.

Additionally, you may ```root``` a package name by prefixing ```/```:

```
$ pkg info runtime/perl
          Name: omniti/runtime/perl
       Summary: perl - Perl 5.14.4 Programming Language
         State: Installed
     Publisher: ms.omniti.com
       Version: 5.14.4 (5.14.4)
 Build Release: 5.11
        Branch: 0.151004
Packaging Date: March 19, 2013 07:14:25 PM 
          Size: 70.39 MB
          FMRI: pkg://ms.omniti.com/omniti/runtime/perl@5.14.4,5.11-0.151004:20130319T191425Z

          Name: runtime/perl
       Summary: Perl 5.16.1 Programming Language
         State: Installed
     Publisher: omnios
       Version: 5.16.1
 Build Release: 5.11
        Branch: 0.151006
Packaging Date: May  7, 2013 07:10:35 PM 
          Size: 30.23 MB
          FMRI: pkg://omnios/runtime/perl@5.16.1,5.11-0.151006:20130507T191035Z


$ pkg info /runtime/perl
          Name: runtime/perl
       Summary: Perl 5.16.1 Programming Language
         State: Installed
     Publisher: omnios
       Version: 5.16.1
 Build Release: 5.11
        Branch: 0.151006
Packaging Date: May  7, 2013 07:10:35 PM 
          Size: 30.23 MB
          FMRI: pkg://omnios/runtime/perl@5.16.1,5.11-0.151006:20130507T191035Z
```

### The pkg Command

Your main interface to IPS packages is via the **pkg(1)** command. It
is similar in function to apt or yum, in that it both manages local
package manipulation as well as locating and querying available packages
from a repository.

Review the **pkg(1)** man page for details.  Here are some common tasks.

#### Configure Publishers

| Command                                                                   | Description                |
|---------------------------------------------------------------------------|----------------------------|
| ```pkg publisher```                                                       | List configured publishers |
| ```pkg set-publisher -g http://pkg.omniti.com/omniti-ms/ ms.omniti.com``` | Add a publisher            |
| ```pkg unset-publisher ms.omniti.com```                                   | Remove a publisher         |

You can change the repo URL for a publisher without removing it and
re-adding it:

```pkg set-publisher -G http://old-url -g http://new-url <publisher-name>```

#### List

| Command                                                              | Description                                                                                                                |
|----------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------|
| ```pkg list```                                                       | List all installed packages                                                                                                |
| ```pkg info omniti/runtime/perl```                                   | Show detailed information on package omniti/runtime/perl, if a package is not installed, add option “-r” to query remotely |
| ```pkg contents omniti/runtime/perl```                               | List the contents of a package                                                                                             |
| ```pkg contents -t file -o path omniti/runtime/perl```               | List only regular files (i.e. no dir, link, etc.)                                                                          |
| ```pkg contents -t file -o path -a path=\*.pm omniti/runtime/perl``` |  List all files with paths matching a pattern                                                                              |
| ```pkg contents -t depend -o fmri subversion```                      |  List the dependencies of a given package                                                                                  |

See the section below on IPS dependencies for details

#### Search

Search queries follow a structured syntax, with shortcuts. The query
syntax is explained in the pkg(1) man page under the *search*
subcommand. The fields are:

```pkg_name:action_type:key:token```

“pkg\_name” is self-explanatory. “action\_type” refers to the type of
object represented, such as file, dir, link, hardlink, etc. “key” is
what attribute of the object you wish to query, such as path, mode,
owner, and “token” is the value of that key. Missing fields are
implicitly wildcarded, and empty leading fields do not require colons.

A bare query term (containing no colons) matches against the token field
(all leading fields are implicitly wildcarded.) Therefore, ```pkg search
foo``` is equivalent to```pkg search :::foo```.

Search terms are expected to be exact matches (there is no implicit
substring matching.) Simple globbing with '?' and '*' are permitted,
e.g. ```pkg search 'git*'```

* The name of the package that provides something (file, dir, link, etc.) called “git”: ```pkg search -p git``` <-- simple syntax
* Packages delivering directory names matching “pgsql*”: ```pkg search -p 'dir::pgsql*'``` <-- structured syntax
* If your search term is small and/or generic, limiting by action type such as “file” and index “basename” is useful to prune the result set: ```pkg search 'file:basename:ld'```
* Locally-installed packages that depend on a given package: ```pkg search -l -o pkg.name 'depend::system/library/gcc-4-runtime'```
  * Leave out the “-l” to search remotely and find all available packages that depend on the given one.

#### Install/Update/Remove

| Command                                       | Description                                                           |
|-----------------------------------------------|-----------------------------------------------------------------------|
| ```pkg install omniti/runtime/perl```         | Install a package                                                     |
| ```pkg install -nv omniti/runtime/perl```     | Test to see what would be done                                        |
| ```pkg install omniti/runtime/perl@5.16.1```  | Install a specific version of a package                               |
| ```pkg update omniti/runtime/perl@5.16.1```   | Update a package: same as above, substituting “update” for “install”  |
| ```pkg update omniti/runtime/perl@5.14.2```   | You can “downgrade” too, just specify the older version you want      |
| ```pkg update pkg://mypublisher/*```          | Apply only the updates from a single publisher                        |
| ```pkg uninstall omniti/runtime/perl```       | Remove a package                                                      |

#### Audit

| Command                              | Description                                                                                     |
|--------------------------------------|-------------------------------------------------------------------------------------------------|
| ```pkg history```                    | View package change history, use “-l” to get verbose info, including package names and versions |
| ```pkg verify omniti/library/uuid``` | Verify proper package state                                                                     |
| ```pkg fix omniti/library/uuid```    | If a problem is found                                                                           |

For example, let's “corrupt” a file and fix it:

```
# echo foo >> /opt/omni/include/uuid/uuid.h

# pkg verify omniti/library/uuid
PACKAGE                                                                 STATUS 
pkg://ms.omniti.com/omniti/library/uuid                                  ERROR
	file: opt/omni/include/uuid/uuid.h
		Size: 3262 bytes should be 3258
		Hash: cb5c795be0e348b87c714c7f2317ceec89212fdf should be 5a5b9389d3f3f63962380bfb933d4e75c5e995bc

# pkg fix omniti/library/uuid
Verifying: pkg://ms.omniti.com/omniti/library/uuid              ERROR          
	file: opt/omni/include/uuid/uuid.h
		Size: 3262 bytes should be 3258
		Hash: cb5c795be0e348b87c714c7f2317ceec89212fdf should be 5a5b9389d3f3f63962380bfb933d4e75c5e995bc
Repairing: pkg://ms.omniti.com/omniti/library/uuid           
                                                                           

DOWNLOAD                                  PKGS       FILES    XFER (MB)
Completed                                  1/1         1/1      0.0/0.0

PHASE                                        ACTIONS
Update Phase                                     1/1

PHASE                                          ITEMS
Image State Update Phase                         2/2 
```

We can see that a new copy of the offending file has been downloaded and used to replace it.

### IPS Dependencies

There are multiple types of dependencies:

* **require**: Used for packages that are essential to basic functionality of this package.
  Satisfied if the specified package is installed and its version is
  greater than or equal to the version specified in the version constraint
  (aka a “floor” on the version, to the stated level of significance.)
  Package will be installed if it is not already, subject to possible
  additional restrictions on the version (see the “incorporate” type
  below.)
* **optional**: Used for packages that provide non-essential
  functionality.  Satisfied if the specified package is not installed at
  all, or if it is installed and its version is greater than or equal to
  the version specified in the version constraint. Package will not be
  installed if it is not already.
* **incorporate**: Like optional, except that the version constraint
  establishes a “ceiling” as well as a “floor”. The dependency is satisfied
  if the package version matches the version constraint up to the degree of
  significance used in the version constraint.  Will not cause a package to be
  installed if it is not already.
* **exclude**: Used when multiple packages provide overlapping content and would
  conflict with one another.  Satisfied if the specified package is NOT installed.

Dependencies mean that you may not always get the most recent version of
a package from the repository. If a package incorporates on, say,
version 1.0 of a dependent, even if the repo contains version 2.0, pkg
will install the version that satisfies the dependency, as long as it is
available from the repository.

For example, the [perl.omniti.com](http://pkg.omniti.com/omniti-perl/)
publisher provides Perl module distribution packages for both 5.14.x and
5.16.x. In addition to a *require* on ```omniti/runtime/perl```, packages for 5.14.x *require*
the “omniti/incorporation/perl-514-incorporation” package, which does:

```
depend fmri=omniti/runtime/perl@5.14 type=incorporate
```

This means that the version of is constrained to any version that
matches “5.14”, so “5.14.2” matches while “5.16.1” does not. This also
ensures that any additional dist packages that get installed are also
constrained to versions that will work with Perl 5.14.

If you are curious what version will be installed or updated, add “-nv”
to either the install or update subcommands. This will do a dry-run with
verbosity and you'll see something like:

```
# pkg install -nv omniti/runtime/perl
           Packages to install:         1
     Estimated space available:   1.78 TB
Estimated space to be consumed: 130.06 MB
       Create boot environment:        No
Create backup boot environment:        No
          Rebuild boot archive:        No

Changed packages:
ms.omniti.com
  omniti/runtime/perl
    None -> 5.16.1,5.11-0.151002:20120815T143305Z
```

Upgrading
---------

In general, updates within stable releases do not require a reboot.
Exceptions are made in cases of security vulnerabilities or bugs that
affect core functionality.

To see what updates are available, and whether a reboot will be
required, run:

```
pkg update -nv
```

At the top of the output will be some summary information similar to:

```
            Packages to update:       311
     Estimated space available: 214.61 GB
Estimated space to be consumed: 518.12 MB
       Create boot environment:       Yes
     Activate boot environment:       Yes
Create backup boot environment:        No
          Rebuild boot archive:       Yes
```

If “Create boot environment” is Yes, then a reboot will be required.
Upgrading to a new stable release always requires a reboot.

If an update requires a reboot, pkg(1) will automatically create a new
*boot environment* or “BE”. This is a copy of the root filesystem made
via ZFS snapshot and clone. Updates will occur on this copy. When
complete, you will see a message similar to:

```
A clone of omnios exists and has been updated and activated.
On the next boot the Boot Environment omnios-1 will be
mounted on '/'.  Reboot when ready to switch to this updated BE.
```

Issue to boot into the upgraded environment. If, for some reason, you
run into trouble with the new BE, simply choose the old BE name from the
GRUB menu during boot and you will get back to the previous environment.
See [beadm(1M)](http://illumos.org/man/1m/beadm) for how to work with
BEs.

### Upgrading With Non-Global Zones

Zones are completely independent system images, and running pkg update
to upgrade the global zone does not update the zone images. You must
upgrade each of the zones to get the latest packages, which is
especially important when the kernel is updated to keep the system
libraries matching the kernel. If you are moving from one stable release
to another, or the [ReleaseNotes](ReleaseNotes.md) indicate that a reboot is required for a
given weekly release, you will need to follow these steps.

> If you are moving to a new stable release, there may be additional
> steps required. Please refer to the [ReleaseNotes](ReleaseNotes.md) of the desired release
> before performing the update.

The following instructions will always apply an update successfully and
safely:

| Step | Command                                     | Description                                                                                                                                                                        |
|------|---------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1    | ```zlogin <zonename> shutdown -i5 -g0 -y``` | Shut down each zone                                                                                                                                                                |
| 2    | ```zoneadm -z <zonename> detach```          | Detach each zone                                                                                                                                                                   |
| 3    | ```pkg update```                            | Upgrade the global zone                                                                                                                                                            |
| 4    | ```init 6```                                | Reboot the server                                                                                                                                                                  |
| 5    | ```zoneadm -z <zonename> attach -u```       | Attach each zone with minimal update. This ensures that the packages necessary for proper operation match the global zone, but it does **not** update all packages within the zone |
| 6    | ```pkg -R <zonepath>/root update```         | **Optional:** Perform a full package update of the zone's pkg image. You can also do this as a normal 'pkg update' from within the zone                                            |
| 7    | ```zoneadm -z <zonename> boot```            | Boot each zone                                                                                                                                                                     |

Starting with [r151014](ReleaseNotes/r151014.md) you have the option
of using [Linked Image (lipkg) zones](linked_images.md). With linked
image zones, you merely need to shut down each zone, per above, and then
automatically takes care of upgrading every zone with a linked image.
Administrators who do not want to surprise zone tenants with upgrades
may wish to not use linked-image zones, or judiciously use if the
package in question is not in the global zone (and subject to linking).

These instructions can result in more downtime than may be desirable.
The release notes will list any shortcuts for updating the OS with less
downtime, but if you are in any doubt, you should follow the
instructions above.

### Staying On A Release

Prior to r151010, packages for multiple releases were commingled in one
repository. That has since been changed (and retroactively applied to
the r151008 release) so there is no longer any need to do anything
special to remain on the release you currently have installed.

#### Staying on r151006

No special action required-- see above.

#### Staying on current stable

No special action required-- see above.

Enumerating Hardware
--------------------

Determining what hardware you're on is always a fun exercise. Linux
users may be used to looking at to get the make, model and capabilities
of the processor(s). On OmniOS, there are a couple of commands to get
the same data: [psrinfo(1M)](http://illumos.org/man/1m/psrinfo) and
[isainfo(1)](http://illumos.org/man/1/isainfo).

```
$ psrinfo -vp
The physical processor has 4 virtual processors (0 2 4 6)
  x86 (chipid 0x0 GenuineIntel family 6 model 23 step 6 clock 2500 MHz)
        Intel(r) Xeon(r) CPU           E5420  @ 2.50GHz
The physical processor has 4 virtual processors (1 3 5 7)
  x86 (chipid 0x1 GenuineIntel family 6 model 23 step 6 clock 2500 MHz)
        Intel(r) Xeon(r) CPU           E5420  @ 2.50GHz
```

The above shows a 2-socket system with quad-core processors. The bonus
with psrinfo is that you can also see how the cores map to sockets.

Additionally, if you're using hyperthreading:

```
$ psrinfo -vp
The physical processor has 6 cores and 12 virtual processors (0-11)
  The core has 2 virtual processors (0 6)
  The core has 2 virtual processors (1 7)
  The core has 2 virtual processors (2 8)
  The core has 2 virtual processors (3 9)
  The core has 2 virtual processors (4 10)
  The core has 2 virtual processors (5 11)
    x86 (GenuineIntel 206D7 family 6 model 45 step 7 clock 2000 MHz)
      Intel(r) Xeon(r) CPU E5-2620 0 @ 2.00GHz
```

If you're *really* curious about how the system schedules work across
the CPUs, check out [lgrpinfo(1)](http://illumos.org/man/1/lgrpinfo)
which displays the NUMA topology of the system. The scheduler attempts
to schedule threads “near” (in NUMA terms) their associated memory
allocations and potential cache entries.

```
$ lgrpinfo 
lgroup 0 (root):
        Children: 1 2
        CPUs: 0-3
        Memory: installed 32G, allocated 9.6G, free 22G
        Lgroup resources: 1 2 (CPU); 1 2 (memory)
        Latency: 79
lgroup 1 (leaf):
        Children: none, Parent: 0
        CPUs: 0 1
        Memory: installed 16G, allocated 4.4G, free 12G
        Lgroup resources: 1 (CPU); 1 (memory)
        Load: 1.09
        Latency: 49
lgroup 2 (leaf):
        Children: none, Parent: 0
        CPUs: 2 3
        Memory: installed 16G, allocated 5.2G, free 11G
        Lgroup resources: 2 (CPU); 2 (memory)
        Load: 0.806
        Latency: 49
```

The isainfo command shows the hardware capabilities for supported ISAs:

```
$ isainfo -x
amd64: vmx xsave pclmulqdq aes sse4.2 sse4.1 ssse3 popcnt tscp cx16 sse3 sse2 sse fxsr mmx cmov amd_sysc cx8 tsc fpu
i386: vmx xsave pclmulqdq aes sse4.2 sse4.1 ssse3 popcnt tscp ahf cx16 sse3 sse2 sse fxsr mmx cmov sep cx8 tsc fpu
```

To see the installed physical memory size, use
[prtconf(1M)](http://illumos.org/man/1m/prtconf)

```
$ prtconf | grep Memory
Memory size: 32742 Megabytes
```

You can also use prtconf(1M) to look at things like PCI devices. As of
r151006, the new “-d” option to prtconf uses a built-in copy of the PCI
device database to provide vendor info:

```
# prtconf -d
...
    pci, instance #0
...
        pci8086,3c03 (pciex8086,3c03) [Intel Corporation Xeon E5/Core i7 IIO PCI Express Root Port 1b], instance #1
            pci15d9,1521 (pciex8086,1521) [Intel Corporation I350 Gigabit Network Connection], instance #0
            pci15d9,1521 (pciex8086,1521) [Intel Corporation I350 Gigabit Network Connection], instance #1
...
```

We also have [pciutils](http://mj.ucw.cz/sw/pciutils/), which you can
get via:

```
# pkg install pciutils
```

Then you can use **lspci** as you may have previously on other
platforms.

Bit Width of Executables and Libraries (32/64)
----------------------------------------------

OmniOS supports both 32- and 64-bit applications and shared objects. But
if we keep two copies of an executable, where do they live and how does
the system know which one to execute? That's where
[isaexec(3C)](http://illumos.org/man/3c/isaexec) comes in. Read the man
page for details, but suffice to say that isaexec(3C) looks at the list
of supported instruction sets (as defined by
[isalist(5)](http://illumos.org/man/5/isalist)) to determine the
preferred one, and then searches for a like-named subdirectory for the
actual executable file.

You can see the list of available ISAs (Instruction Set Architectures)
with [isalist(1)](http://illumos.org/man/1/isalist):

```
$ isalist
amd64 pentium_pro+mmx pentium_pro pentium+mmx pentium i486 i386 i86
```

We normally target “i386” and “amd64”.

As mentioned above, the binaries for each ISA target are kept in
separate subdirectories below where the program would normally live,
such as ```/usr/bin```. For example, targets may be installed in ```/usr/bin/i386/``` and ```/usr/bin/amd64/```. For a given
program, you'll also see an executable at the normal location, such as ```/usr/bin/curl```.
This is a *isaexec stub* that acts as a wrapper and utilizes isaexec(3C)
to determine which binary to run. This makes it possible for everyone to
just run the program from the “normal” location and get the “best”
version that will run on their hardware.

Let's look at an example:

```
$ cd /usr/bin

$ find . -type f -name curl
./amd64/curl
./curl
./i386/curl

$ ls -l curl
-rwxr-xr-x   1 root     bin         9060 Nov  5 19:19 curl

$ file curl
curl:		ELF 32-bit LSB executable 80386 Version 1, dynamically linked, not stripped, no debugging information available

$ ldd curl
        libc.so.1 =>     /lib/libc.so.1
        libm.so.2 =>     /lib/libm.so.2
```

So this binary is really small (9060 bytes) and isn't linked against
libcurl, libssl, and so forth as one would expect. It's just the stub
that figures out where the \_\_real\_\_ binary is. For packages that
OmniOS adds to the illumos core, this binary is created during the build
process. For illumos binaries, the stub is actually a hard link to ```/usr/lib/isaexec```.

```
$ ls -l i386/curl
-rwxr-xr-x   1 root     bin       155316 Nov  5 19:19 i386/curl

$ file i386/curl
i386/curl:	ELF 32-bit LSB executable 80386 Version 1, dynamically linked, not stripped

$ ldd i386/curl
	libcurl.so.4 =>	 /usr/lib/libcurl.so.4
	libidn.so.11 =>	 /usr/lib/libidn.so.11
	libssl.so.1.0.0 =>	 /lib/libssl.so.1.0.0
        [...]
        libm.so.2 =>     /lib/libm.so.2

$ ls -l amd64/curl
-rwxr-xr-x   1 root     bin       157944 Apr 16  2012 amd64/curl

$ file amd64/curl
amd64/curl:	ELF 64-bit LSB executable AMD64 Version 1, dynamically linked, not stripped, no debugging information available

$ ldd amd64/curl
	libcurl.so.4 =>	 /usr/lib/amd64/libcurl.so.4
	libidn.so.11 =>	 /usr/lib/amd64/libidn.so.11
	libssl.so.1.0.0 =>	 /usr/lib/amd64/libssl.so.1.0.0
        [...]
        libm.so.2 =>     /lib/64/libm.so.2
```

Notice that the 64-bit libraries are similarly segregated in a
subdirectory. Libraries are a little different, since they are not
executed directly but are instead linked in at runtime, and therefore do
not need stub wrappers. 32-bit libs are kept in the base location, such
as ```/usr/lib```, while 64-bit libs are in a subdirectory. The expectation is that ```/usr/lib```
contains *only* 32-bit objects, and that any 64-bit versions will be in ```/usr/lib/amd64```
. This influences our builds, since we need to be careful to preserve
this segregation. If a 64-bit library ends up in ```/usr/lib```, a 32-bit app trying
to link it will crash.

Which of the binaries is preferred? Both i386 and amd64 binaries will
work fine on processors supporting the x86\_64/EM64T ISA. Again, we
return to isalist(1). You can run this command yourself if you're
curious. It works rather like the PATH shell variable-- the list is
processed from left to right and the first match wins. Recalling the
output of isalist(1) above, if an amd64 binary exists, it will be chosen
over the i386 version. This is the behavior when running most programs.

So how do we explicitly run a 32-bit app, even on 64-bit-capable
hardware? For non-illumos builds, we have enhanced the isaexec-stub
functionality to inspect a shell environment variable, ISALIST. The
isaexec stubs that we create will prefer the the list specified in this
variable over what the system supports.

As an example, we'll leave ISALIST unset, truss a shell process, and see
what happens when we run curl. Then we'll ```export ISALIST=i386``` and do it again. The
following truss output is edited for brevity, just to demonstrate the
relevant actions.

With ISALIST unset:

```
$ truss -f -t access,stat,open,exec,sysinfo /usr/bin/curl -o /dev/null http://omniti.com

65682:	execve("/usr/bin/curl", 0x08047BD8, 0x08047BEC)  argc = 4
...
65682:	stat64("/usr/bin/curl", 0x0804787C)		= 0
...
65682:	sysinfo(SI_ISALIST, "amd64 pentium_pro+mmx pentium_pro pentium+mmx pentium i486 i386 i86", 1024) = 68
65682:	access("/usr/bin/amd64/curl", X_OK)		= 0
65682:	execve("/usr/bin/amd64/curl", 0x08047BD8, 0x08047BEC)  argc = 4
```

In the absence of the ISALIST variable, the stub does a
[sysinfo(2)](http://illumos.org/man/2/sysinfo) call to get the supported
ISA list, and chooses the leftmost option (first-match). It then looks
for a binary in the appropriate subdirectory, executing it when found.

With ISALIST=i386:

```
$ ISALIST=i386 truss -f -t access,stat,open,exec,sysinfo /usr/bin/curl -o /dev/null http://omniti.com

65935:	execve("/usr/bin/curl", 0x08047BC8, 0x08047BDC)  argc = 4
...
65935:	stat64("/usr/bin/curl", 0x0804786C)		= 0
...
65935:	access("/usr/bin/i386/curl", X_OK)		= 0
65935:	execve("/usr/bin/i386/curl", 0x08047BC8, 0x08047BDC)  argc = 4
```

There was no sysinfo() call this time due to the isaexec stub reading
ISALIST instead.

Exporting the shell variable ensures that the desired ISA list is used
even by programs called by sub-shells, such as another application
running ```/usr/bin/curl-config``` to discover information like library flags, which differs from
32- to 64-bit.
