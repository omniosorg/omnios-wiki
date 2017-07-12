Intervals Between Stable Releases
=================================

What we're working on between stable releases. Format is like
ReleaseNotes with the most recent interval at the top. Please use
headings for each interval for easier navigation.

r151007
-------

Roadmap:

`* Make ipkg zone upgrades smarter.  Currently they only attempt to install the same version of `“`entire`”` that the global zone has.  This misses some important cases, such as emergency flag-day libc updates.`\
`* gcc 4.8.x, add gcc-go support`\
`* Port `“`kvm`”` zone brand from SmartOS`\
`* Modify `` build such that patch-level version updates don't disturb vendor/site lib paths.`

r151005
-------

Branch the build system, with r151004 representing the release and
master moving forward to r151005. Next release will be r151006.

### Remove Studio 12 Dependency

See ticket:41

### Package Version Changes

Changes in **bold** are expected to be significant/noteworthy. Packages
\~\~crossed out\~\~ have been determined to be unnecessary and therefore
removed.

`* bison 2.6.4`\
`* curl 7.28.0`\
`* flex 2.5.37`\
`* gawk 4.0.1`\
`* `**`gcc`` ``4.7.2`**\
`* ggrep 2.14`\
`* `**`git`` ``1.8.0`**\
`* glib 2.34.1`\
`* gmp 5.0.5`\
`* ~~gnutls~~`\
`* gzip 1.5`\
`* libffi 3.0.11`\
`* libidn 1.25`\
`* ~~libgpg-error~~`\
`* ~~libtasn1~~`\
`* libtool 2.4.2`\
`* `**`libxml2`` ``2.9.0`**\
`* libxslt 1.1.27`\
`* mercurial 2.3.2`\
`* mozilla-nss 3.14`\
`* `**`net-snmp`` ``5.7.2`**\
`* ~~nettle~~`\
`* nspr 4.9.3`\
`* ntp 4.2.7p316`\
`* patch 2.7`\
`* pcre 8.31`\
`* pv 1.3.9`\
`* sigcpp 2.3.1`\
`* sqlite 3.7.14.1`\
`* sudo 1.8.6p3`\
`* `**`swig`` ``2.0.8`**\
`* wget 1.14`\
`* xz 5.0.4`\
`* zlib 1.2.7`
