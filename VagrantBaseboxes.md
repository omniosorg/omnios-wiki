Vagrant Baseboxes
=================

How to create a Vagrant basebox for OmniOS.

Necessary Software
------------------

You will need the following packages installed on the host system being
used to build an OmniOS basebox for Vagrant:

* Virtualbox
* Packer

Definitions
-----------

We provide a packer template and script at:

```
https://github.com/jfqd/omnios-packer
```

These will generate a barebones OmniOS basebox with little beyond the
insecure Vagrant key installed. Ideally all that would be necessary to
then use as the base for your own per-project provisioning through
Vagrant. This template and post install script can be modified to suit
your needs if necessary to produce a basebox configuration that differs
from the ones we publish at <http://omnios.omniti.com/>.

Building the Basebox
--------------------

All steps below assume you are working from the base directory of the
repository checkout above.

### template.json

You may want to edit `template.json` if you need to alter the OmniOS release installed,
use a different ISO mirror, or modify disk or memory settings.

In almost all cases, you will want to leave `:boot_cmd_sequence` untouched.

### postinstall.sh

The `definitions/omnios-stable/postinstall.sh` file details everything installed
and configured on the basebox after OmniOS has been installed.

Additionally, this script configures the nameserver, adds the omniti-ms
IPS publisher, installs the Virtualbox Guest Additions, and sets up the
Vagrant insecure key. Any packages you require to be installed or
configured inside your basebox should be added to this script.

### Building

Once the packer template is modified to suit your needs, you build the
basebox using the following:

```
$ packer build template.json
```

This will take some time. You should see Virtualbox create the new
machine, and if you are running on a local machine (or remotely with X11
forwarding) a new VM window will be displayed where you can watch the
progress of the OmniOS installer.

Once complete, you can import the basebox with vagrant to test it:

```
$ vagrant box add omnios-r151008e-r1 packer_virtualbox_virtualbox.box
```
