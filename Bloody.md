Bloody Release
==============

The OmniOS bloody release uses the master branches of all of the
relevant git repositories. It is always an odd-number, and is one after
the current stable. Right now, bloody is r151015.

Unsigned packages
-----------------

Starting with r151014, we require signature enforcement on packages. If
you wish to switch from a stable release to bloody by using IPS, you
must be cautious. Unless you install bloody from an ISO, USB, or Kayak,
you will need to reduce the “omnios” publisher's signature policy. To do
this is similar to the \[wiki:Upgrade\_to\_r151014 r151014 upgrade
instructions\]:

After shutting down the zones gracefully (zlogin; shutdown -i5 -g0 -y):

It would also be a good idea to take a ZFS snapshot of the zone root in
case it's needed for rollback (such as if there are issues with the zone
upgrade.) where <zoneroot> is the name of the ZFS dataset whose
mountpoint corresponds to the value of *zonepath* in the zone's
configuration. There are child datasets under this one, so we use the
option to recursively snapshot all.

Because each OmniOS release has its own dedicated repo, you will first
need to set the package publisher to the repository for r151014:

Once you move to bloody, you have weakened the OmniOS signature policy.
To upgrade out of bloody to a stable release (if it's possible), you
must change the signature policy of the “omnios” publisher back to
require-signatures, as shown in the \[wiki:Upgrade\_to\_r151014 r151014
upgrade instructions\].

Instability
-----------

A bloody release has no guaranteed way to upgrade out of it, but we
endeavor to make it able to be upgradeable to its next stable release.
The r151013 bloody cycle was upgradable to r151014. The r151011 bloody
cycle was not, due to a mismanaged upgrade of a specific package bug.

Modulo the \[wiki:GrubTooManyBEs limits on number of Boot
Environments\], it's recommended that BEs are kept around in case one
needs to revert. If a can't-upgrade event occurs, a BE created before
that bug could be used to upgrade out to the next stable.
