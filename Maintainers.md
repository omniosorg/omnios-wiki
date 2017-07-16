Maintainers
===========

Gate Maintainer
---------------

Keeping gate (illumos-gate) up-to-date is a two-part process. Keeping up
with upstream illumos-gate is relatively simple task with git. The
current illumos-omnios repository uses the **master** branch to manage
the illumos code that runs underneath OmniOS (and what forms a bloody
release). The **upstream** branch is the main “authoritative” Illumos
upstream which correlates directly to the **master** branch at
<https://github.com/illumos/illumos-gate.git>. Other branches may be
used to track changes in the derivates of other vendors (Delphix,
Joyent, etc.) and such branches should have **upstream\_** prepended to
the branch name. Thanks to [LX Zones](LXZones.md),
**upstream\_joyent** is now a branch in illumos-omnios. A simple
non-conflict merge to tip of upstream should work like this:

```
1. cd /code/omnios-151002/illumos-omnios
2. git checkout upstream
3. git pull https://github.com/illumos/illumos-gate.git master
4. git checkout master
5. git merge upstream
```

Step 5 is the only step that can produce conflicts that require manual
intervention. These will happen either because of OmniOS-specific
changes, or because of the importation of LX Zones (and accompanying
infrastructure).

The attached `illumos-update` script (see below) automates this, modulo the manual
merging if step 5 requires it.

### Cherrypicking from 

The [illumos-joyent repository](https://github.com/Joyent/illumos-joyent) is like
illumos-omnios, in that it is a child of **illumos-gate**. When doing
the initial port of LX Zones, OmniOS development kept track of all of
the illumos-joyent commits to know which ones were cherrypicked and
which ones were not. The last-commit-inspected is in the
[README.OmniOS](https://github.com/omniosorg/illumos-omnios/blob/master/README.OmniOS)
file.

The steps for cherrypicking LX changes are:

```
1. Make sure illumos-omnios has already been merged with the latest illumos-gate
2. See commit hashes between the last one inspected and the current tip of illumos-joyent:master
3. Eliminate the commit hashes that are in illumos-gate (and already in illumos-omnios)
4. Inspect the remaining commits using {{{git show}}} to see if they should be cherrypicked
5. {{{git cherry-pick}}} each commit found to be LX-relevant by step 4
```

Attached is a tarball for an **lx-port-data** that covers all of these
up until the release of [r151022](ReleaseNotes/r151022.md).
**lx-port-data** also includes scripts to implement steps 2-3, and steps
4-5 above. Also attached is a script, `joyent-update`, that uses the (older)
lx-port-data scrtips to implement steps 1-3 together, which allows the
`lx-port-date/cherry-pick-or-not` script to run once for every commit.

Here's a sample session:

```
bloody(~)[0]% joyent-update 
HEY -- pay attention in case any of these FUBAR somehow.
   (Also, make sure you've run 'illumos-update' first.)
Fetching origin
remote: Counting objects: 29, done.
remote: Compressing objects: 100% (27/27), done.
remote: Total 29 (delta 3), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (29/29), done.
From https://github.com/joyent/illumos-joyent
   67ae4a47f8..7f03e7512c  master     -> origin/master
Updating 67ae4a47f8..7f03e7512c
Fast-forward
 usr/src/lib/fm/topo/modules/common/disk/disk.h     |   4 +-
 .../lib/fm/topo/modules/common/disk/disk_common.c  |  38 ++++++
 usr/src/lib/fm/topo/modules/common/ses/ses.c       |  64 +++++++++-
 usr/src/lib/libzfs/common/libzfs_mount.c           |   9 +-
 .../uts/common/io/scsi/adapters/mpt_sas/mptsas.c   | 138 ++++++++++++++++++++-
 5 files changed, 246 insertions(+), 7 deletions(-)
~/ws/illumos-omnios ~/ws/illumos-joyent
Fetching origin
Already up-to-date.
Switched to branch 'upstream_joyent'
Your branch is up-to-date with 'origin/upstream_joyent'.
remote: Counting objects: 29, done.
remote: Compressing objects: 100% (27/27), done.
remote: Total 29 (delta 23), reused 0 (delta 0)
Unpacking objects: 100% (29/29), done.
From /export/home/danmcd/ws/illumos-joyent
 * branch                  HEAD       -> FETCH_HEAD
Updating 67ae4a47f8..7f03e7512c
Fast-forward
 usr/src/lib/fm/topo/modules/common/disk/disk.h     |   4 +-
 .../lib/fm/topo/modules/common/disk/disk_common.c  |  38 ++++++
 usr/src/lib/fm/topo/modules/common/ses/ses.c       |  64 +++++++++-
 usr/src/lib/libzfs/common/libzfs_mount.c           |   9 +-
 .../uts/common/io/scsi/adapters/mpt_sas/mptsas.c   | 138 ++++++++++++++++++++-
 5 files changed, 246 insertions(+), 7 deletions(-)
Switched to branch 'master'
Your branch is up-to-date with 'origin/master'.
At this point, your /export/home/danmcd/ws/illumos-omnios repo has updated joyent bits.
So I'm going to generate new LX port data, starting with:
Last illumos-joyent commit: c2e8ae1922322bdaf71ab72b9fa79a94fca93f9c
     (i.e. commit c2e8ae1922322bdaf71ab72b9fa79a94fca93f9c)
Press RETURN for me to generate...

~/ws/illumos-joyent
~/ws/illumos-gate ~/lx-port-data 
~/lx-port-data 
       4 /export/home/danmcd/lx-port-data/ij-ALL-commits
       2 /export/home/danmcd/lx-port-data/ij-TODO-commits

You should cd to /export/home/danmcd/ws/illumos-omnios and run
/export/home/danmcd/lx-port-data/cherry-pick-or-not.sh
until it runs out of commits to potentially pick.
bloody(~)[0]% cd ws/ill
illumos-core/    illumos-gate/    illumos-kvm-cmd/ illumos-nexenta/
illumos-extra/   illumos-joyent/  illumos-kvm/     illumos-omnios/
bloody(~)[0]% cd ws/illumos-omnios/
bloody(~/ws/illumos-omnios)[0]% ~/lx-port-data/cherry-pick-or-not.sh 
commit 4d9d12261073bfc532764822006c3e7f9643fc75
Author: Robert Mustacchi <rm@joyent.com>
Date:   Thu Apr 13 17:38:32 2017 +0000

    OS-5849 SES topology information needs to search STP Bridge ports
    OS-6058 mpt_sas needs to set bridge-port property for SATA devices
    OS-6059 mptsas_handle_topo_change() can return without locks held
    Reviewed by: Joshua M. Clulow <jmc@joyent.com>
    Reviewed by: Patrick Mooney <patrick.mooney@joyent.com>
    Approved by: Joshua M. Clulow <jmc@joyent.com>

 usr/src/lib/fm/topo/modules/common/disk/disk.h     |   4 +-
 .../lib/fm/topo/modules/common/disk/disk_common.c  |  38 ++++++
 usr/src/lib/fm/topo/modules/common/ses/ses.c       |  64 +++++++++-
 .../uts/common/io/scsi/adapters/mpt_sas/mptsas.c   | 138 ++++++++++++++++++++-
 4 files changed, 238 insertions(+), 6 deletions(-)
Cherry pick it (Y/N)? n
GOING TO SKIP!
Skipping this one.
bloody(~/ws/illumos-omnios)[0]% ~/lx-port-data/cherry-pick-or-not.sh
commit 7f03e7512c8cd583b648bf5431882a6faaa25423 (upstream_joyent)
Author: Jerry Jelinek <jerry.jelinek@joyent.com>
Date:   Wed May 10 19:14:19 2017 +0000

    OS-6114 illumos#7955 broke delegated datasets in lx-brand
    Reviewed by: Robert Mustacchi <rm@joyent.com>
    Approved by: Robert Mustacchi <rm@joyent.com>

 usr/src/lib/libzfs/common/libzfs_mount.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)
Cherry pick it (Y/N)? y
GOING TO CHERRYPICK!
[master 10584d48e4] OS-6114 illumos#7955 broke delegated datasets in lx-brand Reviewed by: Robert Mustacchi <rm@joyent.com> Approved by: Robert Mustacchi <rm@joyent.com>
 Author: Jerry Jelinek <jerry.jelinek@joyent.com>
 Date: Wed May 10 19:14:19 2017 +0000
 1 file changed, 8 insertions(+), 1 deletion(-)
You're on your own now.
bloody(~/ws/illumos-omnios)[0]% git status
On branch master
Your branch is ahead of 'origin/master' by 1 commit.
  (use "git push" to publish your local commits)
nothing to commit, working tree clean
bloody(~/ws/illumos-omnios)[0]% cd ~/lx-port-data/
bloody(~/lx-port-data)[0]% ls -lt *commits
-rw-r--r--   1 danmcd   staff          0 May 11 15:16 ij-TODO-commits
-rw-r--r--   1 danmcd   staff         41 May 11 15:16 ij-picked-commits
-rw-r--r--   1 danmcd   staff         82 May 11 15:16 ij-decided-commits
-rw-r--r--   1 danmcd   staff         41 May 11 15:16 ij-skipped-commits
-rw-r--r--   1 danmcd   staff        164 May 11 15:16 ij-ALL-commits
bloody(~/lx-port-data)[0]% mkdir May11
bloody(~/lx-port-data)[1]% mv *commits May11
bloody(~/lx-port-data)[0]%
```

### Post-merge building.

After a merge is complete, either execute the build (but do not publish)
using the tools in omnios-build repo, or use the `/opt/onbld/bin/nightly` script per
[Developing](Developing.md). If you use the `illumos/build.sh` script from omnios-build, and the
build executes successfully, you will see a prompt similar to:

```
Intentional pause: Last chance to sanity-check before publication!
```

Answer “n” to the prompt so that you don't publish the packages to the
repository.

Once built and packaged (but not published) you can install the new
version locally using the following command:

```
# pkg update -g file:///code/omnios-151002/illumos-omnios/packages/i386/nightly-nd/repo.redist
```

Reboot and test. Once you are satsified with the results, push the
change back to the git repository. Make sure to push both upstream and
master branches, and to push to both src.omniti.com and github.

Release Maintainer
------------------

Packages destined for release must first be published to the
release-candidate repo (http://omnios.int.omniti.net:10002/) and
[cherry-picked](PopulatingRepos.md#Cherry-picking) into the release
repo. Since the rc repo lives on the same machine as release, this can
be done quickly with `file://` URLs.

Attachments
------------------

* [illumos-update](Attachments/illumos-update) added by danmcd
* [joyent-update](Attachments/joyent-update) added by danmcd
* [lx-port-data.tgz](Attachments/lx-port-data.tgz) added by danmcd
