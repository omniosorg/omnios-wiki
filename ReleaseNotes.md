OmniOS Release Notes
====================

* [OmniOS r151022](ReleaseNotes/r151022.md) - Initial release May 12 2017 - **Current LTS and Stable**
* [OmniOS r151020](ReleaseNotes/r151020.md) - Initial release November 4 2016
* [OmniOS r151018](ReleaseNotes/r151018.md) - Initial release April 14 2016
* [OmniOS r151016](ReleaseNotes/r151016.md) - Initial release November 3 2015
* [OmniOS r151014](ReleaseNotes/r151014.md) - Initial release April 3 2015
* [OmniOS r151012](ReleaseNotes/r151012.md) - Initial release October 1 2014
* [OmniOS r151010](ReleaseNotes/r151010.md) - Initial release May 7 2014
* [OmniOS r151008](ReleaseNotes/r151008.md) - Initial release December 5 2013
* [OmniOS r151006](ReleaseNotes/r151006.md) - Initial release May 8 2013
* [OmniOS r151004](ReleaseNotes/r151004.md) - Initial release October 29 2012
* [OmniOS r151002](ReleaseNotes/r151002.md) - Initial release April 2 2012

## Bloody Release

The [bloody release](Bloody.md) has unsigned packages, and is in flux FAR MORE than its stable or LTS peers.

The OmniOS release cycle [explained](ReleaseCycle.md).

Unless specifically noted, any interim (“weekly”) release may be applied
via `pkg update` without a reboot. See [the admin page](GeneralAdministration.md#PackageManagement)
for details on using pkg(1).

Major releases are really all that matter in terms of general support.
Use `pkg info` on packages mentioned in weekly releases to see if you
have the updated version.

To determine the major release your system is on, look at `/etc/release`

```
  OmniOS v11 r151014
  Copyright 2015 OmniTI Computer Consulting, Inc. All rights reserved.
  Use is subject to license terms.
```

or starting with [OmniOS r151018](ReleaseNotes/r151018.md), `uname -v` or `uname -a` will
have it as well:

```
r151018(~)[0]% uname -v
omnios-r151018-ae3141d
r151018(~)[0]% uname -a
SunOS r151018 5.11 omnios-r151018-ae3141d i86pc i386 i86pc
r151018(~)[0]% 
```