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
the branch name. Thanks to \[wiki:LXZones LX Zones\],
**upstream\_joyent** is now a branch in illumos-omnios. A simple
non-conflict merge to tip of upstream should work like this:

Step 5 is the only step that can produce conflicts that require manual
intervention. These will happen either because of OmniOS-specific
changes, or because of the importation of LX Zones (and accompanying
infrastructure).

The attached script (see below) automates this, modulo the manual
merging if step 5 requires it.

### Cherrypicking from 

The [illumos-joyent
repository](https://github.com/Joyent/illumos-joyent) is like
illumos-omnios, in that it is a child of **illumos-gate**. When doing
the initial port of LX Zones, OmniOS development kept track of all of
the illumos-joyent commits to know which ones were cherrypicked and
which ones were not. The last-commit-inspected is in the
[README.OmniOS](https://github.com/omniti-labs/illumos-omnios/blob/master/README.OmniOS)
file.

The steps for cherrypicking LX changes are:

 to see if they should be cherrypicked. 5. each commit found to be
LX-relevant by step 4. }}}

Attached is a tarball for an **lx-port-data** that covers all of these
up until the release of \[wiki:ReleaseNotes/r151022 r151022\].
**lx-port-data** also includes scripts to implement steps 2-3, and steps
4-5 above. Also attached is a script, , that uses the (older)
lx-port-data scrtips to implement steps 1-3 together, which allows the
script to run once for every commit.

Here's a sample session:

### Post-merge building.

After a merge is complete, either execute the build (but do not publish)
using the tools in omnios-build repo, or use the script per
\[wiki:Developing\]. If you use the script from omnios-build, and the
build executes successfully, you will see a prompt similar to:

Answer “n” to the prompt so that you don't publish the packages to the
repository.

Once built and packaged (but not published) you can install the new
version locally using the following command:

Reboot and test. Once you are satsified with the results, push the
change back to the git repository. Make sure to push both upstream and
master branches, and to push to both src.omniti.com and github.

Release Maintainer
------------------

Packages destined for release must first be published to the
release-candidate repo (http://omnios.int.omniti.net:10002/) and
\[wiki:PopulatingRepos\#Cherry-picking cherry-picked\] into the release
repo. Since the rc repo lives on the same machine as release, this can
be done quickly with !file:// URLs.
