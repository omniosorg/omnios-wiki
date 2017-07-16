Linked-Image Changes for r151022 and Later.
===========================================

A side-effect of upgrading to Python 2.7 was updating pkg(5) to a more
modern upstream from Oracle Solaris and OpenIndiana.

This changed some semantics of [Linked-image zones](linked_images.md).
Linked-image zones are no longer as strictly linked to the
parent (global-zone) image as they were. The `-r` flag in pkg(1) can be used
to maintain strict child-image (non-global `lipkg` zone) updates. Some packages
(like `system/library`) have explicit parent-image dependencies, which means they will
still always be updated alongside the global zone. Most other packages
now do not have to synchronize their child-images, or required to be in
synch with their parent images.

Here is an example between a global zone and a single linked-image
non-global zone, showing that non-parent-dependent `shell/bash` can be updated. Note
that from the global zone, the non-global zone is updated only with `-r`.
And also note that inside the non-global zone, it can update without the
parent having to do so as well.

```
bloody(~)[0]% zoneadm list -cv
  ID NAME             STATUS     PATH                           BRAND    IP    
   0 global           running    /                              ipkg     shared
   1 lx0              running    /zones/lx0                     lx       excl  
   2 lx2              running    /zones/lx2                     lx       excl  
   3 lx1              running    /zones/lx1                     lx       excl  
   5 lipkg0           running    /zones/lipkg0                  lipkg    excl  
bloody(~)[0]% sudo pkg update -nv bash
            Packages to update:        1
     Estimated space available: 27.12 GB
Estimated space to be consumed: 35.35 MB
       Create boot environment:       No
Create backup boot environment:      Yes
          Rebuild boot archive:       No

Changed packages:
omnios
  shell/bash
    4.4.12-0.151021:20170418T215800Z -> 4.4.12-0.151021:20170419T204904Z

Planning linked: 0/1 done; 1 working: zone:lipkg0
Linked image 'zone:lipkg0' output:
|      Estimated space available: 483.84 GB
| Estimated space to be consumed:  34.98 MB
|           Rebuild boot archive:        No
`
Planning linked: 1/1 done
bloody(~)[0]% sudo pkg update -nvr bash
            Packages to update:        1
     Estimated space available: 27.12 GB
Estimated space to be consumed: 35.35 MB
       Create boot environment:       No
Create backup boot environment:      Yes
          Rebuild boot archive:       No

Changed packages:
omnios
  shell/bash
    4.4.12-0.151021:20170418T215800Z -> 4.4.12-0.151021:20170419T204904Z

Planning linked: 0/1 done; 1 working: zone:lipkg0
Linked image 'zone:lipkg0' output:
|             Packages to update:         1
|      Estimated space available: 483.84 GB
| Estimated space to be consumed:  35.15 MB
|           Rebuild boot archive:        No
| 
| Changed packages:
| omnios
|   shell/bash
|     4.4.12-0.151021:20170418T215800Z -> 4.4.12-0.151021:20170419T204904Z
`
Planning linked: 1/1 done
bloody(~)[0]% sudo zlogin lipkg0 pkg update -nv bash
 Startup: Refreshing catalog 'ms.omniti.com' ... Done
 Startup: Refreshing catalog 'omnios' ... Done
Planning: Solver setup ... Done (0.734s)
Planning: Running solver ... Done (0.619s)
Planning: Finding local manifests ... Done (0.007s)
Planning: Package planning ... Done (0.055s)
Planning: Merging actions ... Done (0.000s)
Planning: Checking for conflicting actions ... Done (0.122s)
Planning: Consolidating action changes ... Done (0.001s)
Planning: Evaluating mediators ... Done (0.145s)
Planning: Planning completed in 1.85 seconds
            Packages to update:         1
     Estimated space available: 483.84 GB
Estimated space to be consumed:  35.15 MB
       Create boot environment:        No
Create backup boot environment:       Yes
          Rebuild boot archive:        No

Changed packages:
omnios
  shell/bash
    4.4.12-0.151021:20170418T215800Z -> 4.4.12-0.151021:20170419T204904Z

bloody(~)[0]% 
```

Behavior changes
----------------

| Behavior                                               | r151014-r151022                       | r151022 and beyond                    |
|--------------------------------------------------------|---------------------------------------|---------------------------------------|
| Zone publishers                                        | Must match or be a superset of global | Must match or be a superset of global |
| Updating child zone packages when updating global zone | Implicit upgrading regardless         | Unless package is marked as parent-dependent (only system packages like ), implicit upgrading only if flag is used in pkg(1). | 
| Updating child zone package when updating global zone  | No affect on child                    | No affect on child                    |
