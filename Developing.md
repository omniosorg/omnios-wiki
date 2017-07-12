Developing on (and for) OmniOS
==============================

For the first several years of [illumos](http://www.illumos.org/), the
default generic development platform was
[OpenIndiana](http://www.openindiana.org/). It works well enough for
laptops and desktops. OmniOS, while being server-focused, can now also
be used to develop for illumos, either witha stock illumos-gate, or with
OmniOS's illumos-omnios.

People used to using /opt/onbld/bin/nightly on platforms may do so on
OmniOS. An illumos-omnios env file needs a couple of specific settings:

`* Disable SMB printing by using `“”\
`* Stock OmniOS installs the illumos-building gcc version in /opt/gcc-4.4.4/, so `“”`.`\
`* To enable linting, you should set ONLY_LINT_DEFS per the illumos wiki: `“”`.`\
`* If you wish to onu (as opposed to just checking for build sanity), set ONNV_BUILDNUM to the release of the machine you're ONU-ing.  (e.g. If you start with the current LTS release, use `“”`.`

The onu script works if you honor the ONNV\_BUILDNUM setting above.

You will be able to [develop
small](http://kebesays.blogspot.com/2011/03/for-illumos-newbies-on-developing-small.html)
on OmniOS. This is useful for bugfixes and even larger modifications to
existing code.

As mentioned in the blog post, your shell will need to set some
additional variables and modify PATH when in “ws mode”. Highlights
include making sure /opt/onbld/bin, /opt/onbld/bin/i386, and
/usr/ccs/bin are ahead of anything else (e.g. “install” is special to
onbld). Here is a sample from my own .tcshrc file:
