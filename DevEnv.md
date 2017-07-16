Setting Up A Basic Dev Environment
==================================

The default OmniOS install contains only runtime-oriented packages. It
does not include a compiler, linker, system headers, etc. All of those
things are available from the “omnios” publisher, so they are easy to
install, but it's not obvious what the package names are.

To get a basic build environment set up, do the following with root
privileges:

LTS
---

Currently r151014

```
# pkg install developer/gcc48
```

Stable
------

Currently r151020

```
# pkg install developer/gcc51
```

Old LTS
-------

Currently r151006

```
# pkg install developer/gcc47 system/library/math/header-math
```

All releases
------------

```
# pkg install \
  developer/build/autoconf \
  developer/build/automake \
  developer/lexer/flex \
  developer/parser/bison \
  developer/object-file \
  developer/linker \
  developer/library/lint \
  developer/build/gnu-make \
  library/idnkit \
  library/idnkit/header-idnkit \
  system/header \
  system/library/math
```

This will get you enough to build most C/C++ software.

Note that GCC installs into /opt/gcc-<VER>, so you'll need to add its
“bin” directory to your path. For example, on r151020, you would add
**/opt/gcc-5.1.0/bin** to your PATH.

illumos Development
-------------------

If you are going to be working on upstream illumos development, take a
look at the [contribution process overview](http://wiki.illumos.org/display/illumos/How+To+Contribute) for
more information. You might also want to bookmark the [illumos developer's guide](http://illumos.org/books/dev/).
