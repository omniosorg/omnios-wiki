The OmniOS build control script
==================================

Introduction
------------

At its simplest, `buildctl` scans the subdirectories of
`omnios-build/build/.` and runs `./build.sh` in each directory.
Because each subdirectories' `./build.sh` can be arbitrarily
messy, sometimes simply uttering `./buildctl -lb build all` will
not be sufficient for a fire-and-forget built.

Syntax
------

```
cd $OMNIOS_BUILD_SRC/build

./buildctl list {grep-pattern}
./buildctl list-build {grep-pattern}
./buildctl {-lb} build {list of package names or package name subsets}
./buildctl {-lb} build {all}
```  

### list

The `list` command will print an alphabetized list of packages available, or a
list that matches the grep pattern.

### list-build

The `list-build` command will print a list of packages as they are built. Currently,
this is determined by `bash` associative array sorting. The build order is not
a stable interface, and is subject to change.

### build

The `build` command can take two optional flags:

* The `-b` flag stands for “batch”, and if used, will not prompt the
  user yes-or-no for `pkglint` (see below), for package installation
  into `$PKGSRVR` (see below), or when a build failure occurs. The
  default answers when this flag is set are see `-l` for pkglint,
  “yes” for install into `$PKGSRVR`, and “stop” when a build failure
  occurs
* The `-l` flag causes the bypass of `pkglint` checking.  It is
  recommended for now that this flag be used, as not all packages
  in omnios-build are `pkglint`-clean

Environment Variables
---------------------

`buildctl` and several subdirectory `build.sh` scripts use several environment variables to
control various behaviors. These can be placed into the script, or just
exported to the environment prior to invoking `buildctl`.

### PKGSRVR

The PKGSRVR environment variable takes a URL (either `<http://>` or
`<file://>`). It specifies the destination for the built IPS packages. If
it is a `<file://>` URL, buildctl will first run `pkgrepo create` if the
directory does not exist.

### PKGPUBLISHER

For OmniOS, this should always be set to “omnios”. It is the IPS publisher string.

### PREBUILT\_ILLUMOS

If set to a directory, `buildctl` will search out illumos-omnios packages in this
directory. `buildctl` will also attempt to see if the build is still going on based
on contents of this directory. If so, it will block any packages that
depend on “illumos” being built - using pwait(1) to wait for the nightly
build process to finish.

IMPORTANT: At a minimum, a prebuilt-illumos MUST build non-DEBUG
packages with the publisher set to “omnios” or whatever else
PKGPUBLISHER is set to.

### KVM\_ROLLBACK and KVM\_CMD\_ROLLBACK

These two variables should be set to git changeset IDs. buildctl will
roll back the checked-out illumos-kvm and illumos-kvm-cmd trees to the
changeset ID specified. Because these come from a different source with
their own illumos build, sometimes we need to roll back time until
illumos-omnios is caught up.

### KAYAK\_SUDO\_BUILD

Tells the Kayak kernel (kayak-kernel) build.sh to use sudo(1M) instead
of assuming it's being run as root. A build of the whole world should
have kayak-kernel be the last thing to build. kayak-kernel pulls its
bits from either PKGURL (a URL for a source of packages), or PKGSRVR if
PKGURL is not set. The source of packages for kayak-kernel should be
fully populated in advance. [OmniOS-on-demand](OmniOS-on-demand.md)
does this explicitly with PKGSRVR, for example.

### ROOT\_OK

Most `build.sh` scripts should not be run as root, and they will exit immediately
if they are. Setting ROOT\_OK disables the immediate exit if running as
root.

Files
-----

`buildctl` also reads data from some files.

### .../lib/config.sh

Rarely changes, but this file contains more variables for `buildctl` and
subdirectory `build.sh` scripts.

### .../{builddir}/dependencies

While rare, some packages depend on other packages already having been
built and installed in $PKGSRVR. This is distinct from IPS dependencies
or machine environment dependencies, as dependencies in this file are
BUILD-TIME dependencies. The contents of this files are a list of
one-package-per-line packages. Currently only `kayak/` has this file.

Miscellany
----------

Recent versions of `buildctl` will perform duplicate suppression. If a subdirectory
has N packages, that subdirectory's `build.sh` used to be run N times. Duplicate
suppression will reduce N down to 1, IF AND ONLY IF “all” is the list of
packages, or the list of packages use full package names.

A package can be specified by a full package name, or a substring. If a
substring matches more than one full package name, it unspecified which
single full package name will match, but only one will.
