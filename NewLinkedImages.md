Linked-Image Changes for r151022 and Later.
===========================================

A side-effect of upgrading to Python 2.7 was updating pkg(5) to a more
modern upstream from Oracle Solaris and !OpenIndiana.

This changed some semantics of \[wiki:linked\_images Linked-image
zones\]. Linked-image zones are no longer as strictly linked to the
parent (global-zone) image as they were. The flag in pkg(1) can be used
to maintain strict child-image (non-global zone) updates. Some packages
(like ) have explicit parent-image dependencies, which means they will
still always be updated alongside the global zone. Most other packages
now do not have to synchronize their child-images, or required to be in
synch with their parent images.

Here is an example between a global zone and a single linked-image
non-global zone, showing that non-parent-dependent can be updated. Note
that from the global zone, the non-global zone is updated only with .
And also note that inside the non-global zone, it can update without the
parent having to do so as well.

Behavior changes
----------------

|| Behavior || **r151014-r151022** || **r151022 and beyond** || || || ||
|| || Zone publishers || Must match or be a superset of global. || Must
match or be a superset of global. || || Updating child zone packages
when updating global zone || Implicit upgrading regardless. || Unless
package is marked as parent-dependent (only system packages like ),
implicit upgrading only if flag is used in pkg(1). || || Updating child
zone package when updating global zone || No affect on child. || No
affect on child. ||
