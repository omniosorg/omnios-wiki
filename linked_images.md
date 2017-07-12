Linked Image Zones
==================

Starting with \[wiki:ReleaseNotes/r151014 r151014\], the ability to have
linked-image zones is available. In OmniOS, we chose to make
linked-images an option, available through the “lipkg” brand zone. The
only difference between an ipkg zone (the normal zone type for OmniOS)
and lipkg zones is the linking of images.

A linked-image zone either has the same, or a superset, of publishers as
the global zone has.

What *are* linked images?
-------------------------

### r151014 through r151020

Linked images link the packages in a zone to the global zone. If you
update the global zone's packages, the linked-image zones get updated
alongside it. This means going forward, an upgrade with linked image
zones does not require detaching and reattaching the zone. You can
update zones on a running system (at the cost of losing some log state
during the time of the upgrade and the time of a reboot), or you can
simply halt the zones, do the upgrade, and reboot with all linked-image
zones automatically updated.

### r151022 and beyond

It has \[wiki:NewLinkedImages its own page\], but in a nutshell, the
linkage in linked-image zones weakens some, unless you are using the
new-in-\[wiki:ReleaseNotes/r151022 r151022\] “-r” flag for pkg(1).

How do I use linked images with my zones?
-----------------------------------------

Normal OmniOS zones are “ipkg” branded. To change a zone's brand, you
must detach it first, and then reattach it.

Once the brand is changed, <zonename> will have its IPS image linked to
the global zone's image. When you update the global zone, <zonename>
will have its software updated as well. One potential side-effect of
this is that the zone may get software more new than the zone's tenant
(if you have tenants on your zone) can cope with. It's this side effect
that kept us from just making linked-images the default on ipkg zones,
and prompted us to create the lipkg brand.
