Virtual Machines with KVM
=========================

**NOTE: THIS IS A WORK IN PROGRESS. COME BACK WHEN THIS NOTE IS GONE.**

Starting a VM
-------------

Each KVM virtual machine requires a **dedicated** virtual network
interface (card), HDD (a ZFS Volume, aka. zvol, will do) and VNC TCP
port.

### Create vnic

Find the physical device to build it on top:

Create a virtual network interface on top of :

### Setup ISO and HDD

Download an ISO:

Prepare a volume for the VM:

<size> should be an appropriately-sized virtual disk. E.g. 32G.

<pool> and <zvol-name> represent a pool, and a name of a ZFS Volume. The
-V flag indicates you're creating a ZFS Volume, and an entry in
/dev/zvol/dsk/<pool>/<zvol-name>.

### Start Virtual Machine

You can use the following script to start the VM:

#### Notes

`* script credit: `[`John`` ``Grafton's`` ``blog`](http://www.graymatterboundaries.com/?p=158)\
`* `*`configuration`` ``settings`*` on the top of the script are in `**`UPPERCASE`**\
`* multiple VMs: customize ``, `` and `\

#### Next steps

When completed, use a VNC client to connect to the and install FreeBSD
into the VM.

During the installation, make sure to enable and add a local user
account for yourself. on FreeBSD does not by default.

**Note:** In case your host system is connected via DHCP to your local
network, DHCP should work for the guest's OS as well.

Once the installation completed and the guest rebooted, the guest should
boot FreeBSD from its HDD right away. Access the FreeBSD guest using VNC
or .

Using a script to start VM guests also makes it easy to put them under
SMF control. Here's a sample manifest (replace '@@VM\_NAME@@' with your
VM name):

Troubleshooting
---------------

### /usr/bin/qemu-kvm on OmniOS

The binary is called:

### /dev/kvm - no such device

First ensure kvm is loaded:

If the module is not present, load it with:

This is a one-time setup and will persist across reboots.

Setting up KVM in a zone.
-------------------------

You may run a KVM instance in a non-global zone so long as:

`* The zone has its own vNIC so KVM's VNC server can run.`

`* The KVM's vNIC is provisioned into the zone's creation by using zonecfg(1M)'s `“`add`` ``net`”` command.`

`* The zvol is named such that its parent dataset can be delegated to the zone, and that its zvol device path is provisioned into the zone's creation by using zonecfg(1M)'s `“`add`` ``device`”` command.  One can provide a number of zvols to a zone this way:`

Once those resources are available to a zone, you can run the shell
script or import the SMF service per above.
