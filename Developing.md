Developing on (and for) OmniOS
==============================

For the first several years of [illumos](http://www.illumos.org/), the
default generic development platform was
[OpenIndiana](http://www.openindiana.org/). It works well enough for
laptops and desktops. OmniOS, while being server-focused, can now also
be used to develop for illumos, either witha stock illumos-gate, or with
OmniOS's illumos-omnios.

People used to using `/opt/onbld/bin/nightly` on platforms may do so on
OmniOS. An illumos-omnios env file needs a couple of specific settings:

* Disable SMB printing by using `export ENABLE_SMB_PRINTING='#'`
* Stock OmniOS installs the illumos-building gcc version in `/opt/gcc-4.4.4/`,
  so `export GCC_ROOT=/opt/gcc-4.4.4`
* To enable linting, you should set `ONLY_LINT_DEFS` per the illumos wiki:
  `export ONLY_LINT_DEFS=-I${SPRO_ROOT}/sunstudio12.1/prod/include/lint`
* If you wish to onu (as opposed to just checking for build sanity), set
  `ONNV_BUILDNUM` to the release of the machine you're ONU-ing. (e.g. If
  you start with the current LTS release, use `export ONNV_BUILDNUM=151022`)

The onu script works if you honor the ONNV\_BUILDNUM setting above.

You will be able to [develop small](http://kebesays.blogspot.com/2011/03/for-illumos-newbies-on-developing-small.html)
on OmniOS. This is useful for bugfixes and even larger modifications to
existing code.

As mentioned in the blog post, your shell will need to set some
additional variables and modify PATH when in “ws mode”. Highlights
include making sure /opt/onbld/bin, /opt/onbld/bin/i386, and
/usr/ccs/bin are ahead of anything else (e.g. “install” is special to
onbld). Here is a sample from [my](http://kebesays.blogspot.com) own .tcshrc file:

```
if ( $?CODEMGR_WS ) then
	set prompt="WS-%m-WS(%c2)[%?]%% "
	set path = ( /opt/onbld/bin /opt/onbld/bin/i386 /usr/ccs/bin \
	     /export/home/danmcd/bin /bin /usr/bin /usr/local/bin \
	     /usr/sbin /sbin /opt/omni/bin /opt/onbld/bin /opt/SUNWspro/bin )
	setenv BUILD_TOOLS /opt
	setenv SPRO_ROOT /opt/SUNWspro
	setenv ONBLD_TOOLS /opt/onbld
	# For OmniOS, use GCC, and ONLY gcc.
	setenv __GNUC ""
	setenv CW_NO_SHADOW 1
else
	set prompt="%m(%c2)[%?]%% "
	set path = ( /export/home/danmcd/bin /bin /usr/bin /usr/local/bin \
	     /usr/sbin /sbin /opt/omni/bin /opt/onbld/bin /opt/SUNWspro/bin )
endif
```