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

```
root@server:~# dladm show-link
LINK        CLASS     MTU    STATE    BRIDGE     OVER
igb0        phys      1500   up       --         --
igb2        phys      1500   down     --         --
igb1        phys      1500   down     --         --
igb3        phys      1500   down     --         --
```

Create a virtual network interface on top of ´igb0´:

```
root@server:~# dladm show-vnic
LINK         OVER         SPEED  MACADDRESS        MACADDRTYPE         VID
root@server:~# dladm create-vnic -l igb0 vnic0
root@server:~# dladm show-vnic
LINK         OVER         SPEED  MACADDRESS        MACADDRTYPE         VID
vnic0        igb0         100    2:8:20:38:a5:d6   random              0
```

### Setup ISO and HDD

Download an ISO:

```
# mkdir -p /export/vm
# cd /export/vm
# wget ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/ISO-IMAGES/9.1/FreeBSD-9.1-RC2-amd64-disc1.iso
```

Prepare a volume for the VM:

```
# zfs create -V <size> <pool>/<zvol-name>
```

<size> should be an appropriately-sized virtual disk. E.g. 32G.

<pool> and <zvol-name> represent a pool, and a name of a ZFS Volume. The
`-V` flag indicates you're creating a ZFS Volume, and an entry in
`/dev/zvol/dsk/<pool>/<zvol-name>`.

### Start Virtual Machine

You can use the following script to start the VM:

```
#!/usr/bin/bash

# configuration
VNIC=vnic0
# Sample zvol path.
HDD=/dev/zvol/rdsk/rpool/vm-zvol
# NOTE: You can add more... (see NOTE2 below)
#HDD2=/dev/zvol/rdsk/data/vm-data-zvol
CD=/export/iso/FreeBSD-9.1-RC2-amd64-disc1.iso
VNC=5
# Memory for the KVM instance, in Megabytes (2^20 bytes).
MEM=1024

mac=`dladm show-vnic -po macaddress $VNIC`

/usr/bin/qemu-system-x86_64 \
-name "$(basename $CD)" \
-boot cd \
-enable-kvm \
-vnc 0.0.0.0:$VNC \
-smp 2 \
-m $MEM \
-no-hpet \
-localtime \
-drive file=$HDD,if=ide,index=0 \
-drive file=$CD,media=cdrom,if=ide,index=2  \
-net nic,vlan=0,name=net0,model=e1000,macaddr=$mac \
-net vnic,vlan=0,name=net0,ifname=$VNIC,macaddr=$mac \
-vga std \
-daemonize

# NOTE2: Add an additional -drive file=$HDD2,if=ide,index=X for a unique X
# in the big command-line above if you want another drive.  Repeat as needed.

if [ $? -gt 0 ]; then
    echo "Failed to start VM"
fi

# TCP port for VNC connections to the KVM instance.  5900 is added in the command.
port=`expr 5900 + $VNC`
public_nic=$(dladm show-vnic|grep vnic1|awk '{print $2}')
public_ip=$(ifconfig $public_nic|grep inet|awk '{print $2}')

echo "Started VM:"
echo "Public: ${public_ip}:${port}"
```

#### Notes

* script credit: [John Grafton's blog](http://www.graymatterboundaries.com/?p=158)
* *configuration settings* on the top of the script are in **UPPERCASE**
* multiple VMs: customize `VNIC`, `VNC` and `HDD`

#### Next steps

When `./start-vm.sh` completed, use a VNC client to connect to the `IP:PORT` and install FreeBSD
into the VM.

During the installation, make sure to enable and add a local user
account for yourself. on FreeBSD does not by default.

**Note:** In case your host system is connected via DHCP to your local
network, DHCP should work for the guest's OS as well.

Once the installation completed and the guest rebooted, the guest should
boot FreeBSD from its HDD right away. Access the FreeBSD guest using VNC
or .

Using a script to start VM guests also makes it easy to put them under
SMF control. Here's a sample manifest (replace '@@VM_NAME@@' with your
VM name):

```
<?xml version='1.0'?>
<!DOCTYPE service_bundle SYSTEM '/usr/share/lib/xml/dtd/service_bundle.dtd.1'>
<service_bundle type='manifest' name='export'>
    <service name='kvm/@@VM_NAME@@' type='service' version='0'>
        <create_default_instance enabled='true'/>
        <single_instance/>
        <dependency name='network' grouping='require_all' restart_on='none' type='service'>
            <service_fmri value='svc:/milestone/network:default' />
        </dependency>
        <dependency name='filesystem' grouping='require_all' restart_on='none' type='service'>
            <service_fmri value='svc:/system/filesystem/local:default' />
        </dependency>
        <exec_method name='start' type='method' exec='/path/to/start-script' timeout_seconds='60'/>
        <exec_method name='stop' type='method' exec=':kill' timeout_seconds='60'/>
        <stability value='Unstable'/>
        <template>
            <common_name>
                <loctext xml:lang='C'>KVM-@@VM_NAME@@</loctext>
            </common_name>
        </template>
    </service>
</service_bundle>
```

Troubleshooting
---------------

### /usr/bin/qemu-kvm on OmniOS

The binary is called: `/usr/bin/qemu-system-x86_64`

### /dev/kvm - no such device

First ensure kvm is loaded:

```
# modinfo |grep kvm
205 fffffffff80a5000  39ff0 264   1  kvm (kvm driver v0.1)
```

If the module is not present, load it with:

```
# add_drv kvm
```

This is a one-time setup and will persist across reboots.

Setting up KVM in a zone.
-------------------------

You may run a KVM instance in a non-global zone so long as:

* The zone has its own vNIC so KVM's VNC server can run
* The KVM's vNIC is provisioned into the zone's creation by using
  zonecfg(1M)'s “add net” command
  ```
  zonecfg> add net
  zonecfg> set physical=vnic0
  zonecfg> end
  ```
* The zvol is named such that its parent dataset can be delegated
  to the zone, and that its zvol device path is provisioned into
  the zone's creation by using zonecfg(1M)'s “add device”
  command.  One can provide a number of zvols to a zone this way:
  ```
  zonecfg> add device
  zonecfg> set match="/dev/zvol/rdsk/rpool/zvol/*"
  zonecfg> end
  zonecfg> add dataset
  zonecfg> set name=rpool/zvol
  zonecfg> end
  ```

Once those resources are available to a zone, you can run the shell
script or import the SMF service per above.
