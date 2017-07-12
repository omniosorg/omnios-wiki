Making a Weekly Release
=======================

\[wiki:PopulatingRepos\#Cherry-picking Cherry-pick\] the desired
package(s) from the RC repo into the release repo.

On the release repo server:

`1. Review package differences between the current state of the filesystem and the snapshot of the previous release: `\
`   * `\
`1. Snapshot repo dataset @`<release><letter>`, e.g. `“`r151002a`”\
`1. Prepare [wiki:ReleaseMedia] if there are security fixes or significant changes to packages provided by default, such as driver updates.`\
`  a. Update symlinks for latest release to point at the new media, as appropriate (LTS or Stable), see below for details.`\
`1. Update [wiki:ReleaseNotes] with what changed.`\
`1. Announce to #omnios on IRC, Twitter w/hashtags #OmniOS and #illumos, and on omnios-discuss list.`

Updating symlinks
-----------------

These links should always point to the most recent media:
