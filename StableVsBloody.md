Stable vs. Bloody
=================

**OmniOS stable** is designed to be run in production with minimal
disruption. This means we release updates in a way to minimize service
disruption (reboot). Kernel updates are only made if they are security-
or stability-related and no work-around exists. User-space applications
can be treated more aggressively, but we're still conservative.
Non-disruptive updates are made available weekly (if there's anything to
update) and a full stable release is done every six months. Updates to
new stable releases will always require a reboot.

Stable releases occur at approximately 6-month intervals and have even
numbers, such as “r151004”, which was released in October 2012.

**OmniOS bloody** incorporates user-land updates and kernel updates in
an aggressive fashion and updates are made available as they are
introduced via IPS.

The only time we see install media rolled for stable is if there is a
specific security or installation-related issue addressed by a change.
Install media for bloody are updated periodically but not on a set
schedule.

Users can always obtain the latest-available packages on their systems
via `pkg update`. See the [Package Management](GeneralAdministration.md#PackageManagement)
wiki page for more information.
