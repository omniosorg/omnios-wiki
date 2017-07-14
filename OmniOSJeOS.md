OmniOS Approach
===============

**Video: [Motivation and Design](https://www.usenix.org/conference/lisa12/omnios-motivation-and-design)**
/ Theo Schlossnagle lays out the case for OmniOS at Usenix LISA '12.

Goal: Produce a self-hosting, minimalist Illumos-based release suitable
for production deployment

We're not looking for a minimal appliance install, but a fully
functional service install without extraneous dependencies causing
package management issues and relentless disruptive upgrades for
packages unrelated to the operation of the system.

We started with an !OpenIndiana system that we attempted to reduce, but
we found package inter-dependencies caused a large amount of additional
software to be installed that we did not want. Changing those
dependencies would require rebuilding the affected packages, but
(re)building OI packages proved a challenge. Many of the packages we
wanted to keep were also quite dated. At any rate, the moment we change
a single package we “own” the resulting build in the sense that we are
responsible for upkeep. The OmniOS project takes this to its logical
conclusion -- create a wholly-customized OS and reduce OI dependencies
to zero.

The OmniOS system should be
[self-hosting](http://en.wikipedia.org/wiki/Self-hosting), that is,
capable of building new versions of itself, on itself.

Methodology
-----------

* Start with an Illumos build
* Bootstrap packages that replace their equivalents in OI
* Strip out anything not essential to booting and running a minimal system, see [Keep Your S**t To Yourself](KYSTY.md)
  * The [OmniOS package repository](http://omnios.omniti.com/omnios/release) provides more packages than the bare essentials (toolchains to support self-hosting, for instance) but these packages are not defined for a typical install
* Build with GCC instead of Sun/Solaris Studio wherever possible, but continue to use ```/usr/ccs/bin/ld``` and **not** GNU ld
* Locate non-core user-land packages in a different publisher/repo. See a [list of third-party repos](Packaging.md).

Ultimately others in the community should be able to take our build
scripts and documentation and roll their own copy of the system.

## Incorporations

Incorporations are packages that only depend on other packages. They
provide no filesystem content of their own.

We use as few incorporations as possible. They have proven to cause at
least as many problems as they purport to solve. Primarily they are
supposed to prevent upgrading to package versions that create
incompatibilities with other installed software. This is particularly
important for shared libraries. We intend to solve that problem
differently, by bringing in the most current versions of software for
the first release (2012) and maintaining those versions for the lifetime
of that release. This is similar to the strategy used by CentOS and
other enterprise Linux vendors.

That said, incorporations are still useful to keep together the set of
packages that constitute a stable release, e.g. “r151004”.

### entire

Governs which packages are installed on every system. This is the
minimal set for running an OmniOS system.

### illumos-gate

Constrains the version of all packages delivered by the upstream
illumos-gate source. Contains only dependencies of type “incorporate”,
which is an optional dependency. Installing illumos-gate does not cause
all dependent packages to be installed, but if they are installed at
some point, their version is constrained to the degree specified in the
dependency.

```
depend fmri=system/management/intel-amt@0.5.11,5.11-0.151004 type=incorporate
```

The above constrains the intel-amt package to version
```0.5.11,5.11-0.151004:*```. This excludes, for example, versions
```0.5.11,5.11-0.151002:*``` and ```0.5.11,5.11-0.151005:*```, but permits
updated versions that match up to the branch (0.151004) but bear more
recent timestamps.

### omnios-userland

New incorporation for r151004 that performs the same function as
illumos-gate but for the additional software provided by OmniOS.

Major Updates
-------------

These were the highlights of the initial stable release (r151002):

* GNU binutils 2.22
* GCC 4.6.3 (for user-land)
* OpenSSL 1.0.1
* python 2.6 only (dual 32/64)
* perl 5.14.2 (dual 32/64)
* zlib 1.2.6
* libxml2 2.7.8

While we took build hints from Oracle's still-open “userland-gate” repo,
such as patches and configuration options, we do not use any of
userland-gate's build plumbing.

## High-Level Components

The major pieces that come together to make OmniOS are as follows. Hit
“Browse” in the top menu bar to explore the actual sources.

### illumos-omnios

Our copy of illumos-gate, [minimally modified](ReleaseNotes.md) to
support things like dual-arch Python, newer OpenSSL.

### caiman

The installer used for CD/USB media. “Project Caiman” is a replacement
for the traditional Solaris installer, incorporating features like Live
CD/DVD and an updated GUI. Given our goal of a simplified, stripped-down
install, we kept only the bare essential text install pieces and
eliminated the rest. We also modified it to run under our dual-arch
Python in much the same way as pkg(5).

### pkg(5)

pkg provides the IPS pkg toolchain. The upstream build provides only
32-bit python native extensions which is problematic with our dual
32/64-bit python build. Our fork of pkg alters the build system to build
the native extensions on both architectures and removes GUI-dependent
components leaving the bare minimum required for complete IPS packaging
(including the branded zone).

### kayak

An alternative to Solaris 11's Automated Installer (AI). Features a
simple, extensible configuration syntax (a.k.a bash) and delivers the
installation as a ZFS stream.

Notable features not found in AI:

* Mirrored boot pool (simple mirrors only)
* compression=on for rpool by default

See the [network installation](Installation.md#Fromthenetwork) section for more details.

### omnios-build

Build scripts that tie together the above pieces and also provide the
rest of the packages.
