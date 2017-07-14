VMware Notes
============

OmniOS will run just fine on recent VMware products, with a few caveats.

Installing VMware Tools
-----------------------

Follow the directions for [installing VMware Tools in a Solaris guest](http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1023956)

Attach a virtual floppy
-----------------------

If running the text installer from the [Installation#FromCDisoISO](Installation.md#FromCDisoISO),
the guest must have a virtual floppy device configured or it will
hang during installation. Either add the device via the VMware GUI or
add the following to your .vmx file:

```
floppy0.fileType = "file"
floppy0.fileName = "path_to_/floppy_image/Omni.flp"
floppy0.clientDevice = "FALSE"
floppy0.startConnected = "FALSE"
```

Credit: <http://thewayeye.net/2012/june/1/installing-omnios-under-vmware-fusionworkstation>

The floppy image can be an empty file, but it must exist. If the floppy
is the default boot device (which is the case if you add it through the
VMware GUI), your VM will boot into Pong - (see
<http://communities.vmware.com/message/1454298>).

Use recent release
------------------

The r151002w ISO, which contains text-installer fixes for device
detection under VMware, is required. These fixes were previously only
available in “bloody”.

**As of r151004, this is no longer an issue in either stable or
bloody.**
