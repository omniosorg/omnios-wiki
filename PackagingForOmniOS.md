Introduction
============

This page describes how to package open source software for OmniOS. The
current system largely resembles other source-based packaging systems
like FreeBSD ports, pkgsrc, or Gentoo portage. The user writes a few
metadata files in plain text, and these serve as a driver for the system
to create the package.

The build system consists of a collection of shell scripts and
associated metadata files which the shell scripts read to produce
packages.

To find out more about the Image Packaging System, please see
\[wiki:MoreInfo\#IPSpkg5 the More Info page\]. In particular the
Developer's Guide explains the key concepts in IPS that you'll need to
successfully create and maintain packages for OmniOS.

Repository layout
=================

The package metadata lives in a git repository, accessible at
\`anon@src.omniti.com:\~omnios/core/omnios-build\`. This directory has
the following structure:

The \`build\` directory contains the package-specific metadata, with
\`template\` containing various templates for common projects and
\`lib\` housing various shell functions used by the system. \`new.sh\`
is used to create a directory

Your First OmniOS package
=========================

Run the \`new.sh\` script with the name of the package you want to
create for OmniOS. For example:

This will create an entry \`build/example\` with the following layout:

The \`build.sh\` script is pretty basic; here are the uncommented
portions:

Most things here should be self-explanatory. The PKG variable should be
set to the category and name of the package, but not include a publisher
name. See \[wiki:GeneralAdministration\#FMRIFormat\] for details on
package names. VERHUMAN preserves the upstream version in case it
contains something other than numbers and dots. The package author may
need to code up a conversion scheme so that VER conforms to IPS format.
The value of VERHUMAN will be placed in the **pkg.human-version** key in
the package, which is displayed in parentheses following the IPS
component version in the output of 'pkg info', e.g.:

Useful configuration options:

`* $MIRROR is defined in lib/config.sh and defines the base URL from which the package will be downloaded. `` tries to download from $MIRROR/$PROG/$PROG-$VER.*. There is a 4th argument to download_source that specifies where to build the package.`\
`* $PKGSRVR and $PKGPUBLISHER from lib/site.sh configure where the package gets published. See [wiki:CreatingRepos] for info on creating a repo.`

Most items there are self-explanatory and in general shouldn't be
changed for the usual case.

Given all of this, it should be fairly simple to build basic packages.
Shell variables set in build.sh will be available to the build process,
so things like \`\$LDCLFAGS\` and \`\$CFLAGS\` work as expected.

Best practice is to provide a \`local.mog\` file along with the build.sh
for licensing. Its format is the following:

This helps inform users about the legal terms of using the packaged
software.

Troubleshooting
===============

In the event of problems, \`build.sh\` leaves a log file, \`build.log\`.
This should make any problems immediately evident, though solving them
is left as an exercise for the reader. ;)

More Information
================

`* `[`Introduction`` ``to`` ``IPS`](http://www.slideshare.net/esproul/ips-image-packaging-system)` (slide stack, also available in `[`PDF`](http://omnios.omniti.com/media/IPS_Intro.pdf)`)`\
`* `[`pkg(5):`` ``Image`` ``Packaging`` ``System`](http://en.wikipedia.org/wiki/Image_Packaging_System)\
`* `[`Packaging`` ``and`` ``Delivering`` ``Software`` ``with`` ``the`` ``Image`` ``Packaging`` ``System:`` ``A`` ``Developer's`` ``Guide`](http://omnios.omniti.com/media/ipsdevguide.pdf)\
`* `[`IPS`` ``Project`` ``at`` ``java.net`](https://java.net/projects/ips)
