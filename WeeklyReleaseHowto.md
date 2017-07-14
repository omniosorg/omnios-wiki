Making a Weekly Release
=======================

[Cherry-pick](PopulatingRepos.md#Cherry-picking) the desired
package(s) from the RC repo into the release repo.

On the release repo server:

1. Review package differences between the current state of the filesystem and the snapshot of the previous release:
   ```
   # zfs diff data/set/omnios/repo/release@<release><letter-prev> data/set/omnios/repo/release | grep pkg
   ```
1. Snapshot repo dataset @<release><letter>, e.g. “r151002a”
1. Prepare [ReleaseMedia](ReleaseMedia.md) if there are security fixes
   or significant changes to packages provided by default, such as
   driver updates
   * Update symlinks for latest release to point at the new media, as
     appropriate (LTS or Stable), see below for details
1. Update [ReleaseNotes](ReleaseNotes.md) with what changed
1. Announce to #omnios on IRC, Twitter w/hashtags #OmniOS and #illumos,
   and on omnios-discuss list

Updating symlinks
-----------------

These links should always point to the most recent media:

```
OmniOS_Text_Stable_latest.iso
OmniOS_Text_Stable_latest.usb-dd
OmniOS_Kayak_Stable_latest.zfs.bz2
OmniOS_Text_LTS_latest.iso
OmniOS_Text_LTS_latest.usb-dd
OmniOS_Kayak_LTS_latest.zfs.bz2
```
