More Information
----------------

[OmniOS Motivation and
Design](https://www.usenix.org/conference/lisa12/omnios-motivation-and-design)
/ Theo lays out the case for OmniOS at Usenix LISA '12.

OmniOS is a distribution of **illumos**, and as such, many aspects of
the system's function are derived from the illumos core, which has its
own documentation. Additionally, technologies like ZFS and DTrace, which
have been ported to non-illumos operating systems, have their own
communities of wisdom from which we all benefit.

### illumos

`* `[`The`` ``illumos`` ``Project`](https://www.illumos.org/)\
`* `[`Fork`` ``Yeah:`` ``The`` ``Rise`` ``and`` ``Development`` ``of`` ``Illumos`](http://www.youtube.com/watch?v=-zRN7XLCRhc)` (youtube.com)`\
`* `[`illumos`` ``developer's`` ``guide`](http://illumos.org/books/dev/)\
`* `[`CDDL`` ``License`](http://illumos.org/license/CDDL)\
`* `[`Lesser-Known`` ``Solaris`` ``Features`](http://www.c0t0d0s0.org/pages/lksfbook.html)` (despite the title, very much applicable to any illumos system)`

### ZFS

`* `[`ZFS`` `“`Read`` ``Me`` ``1st`”](http://nex7.blogspot.com/2013/03/readme1st.html)\
`* `[`Bacon`` ``Preservation`` ``with`` ``ZFS`](http://sysadvent.blogspot.com/2012/12/day-7-bacon-preservation-with-zfs.html)\
`* `[`zfsday`` ``Videos`](http://zfsday.com/zfsday/)\
`* `[`RaidZ`` ``Striping`](http://joyent.com/blog/zfs-raidz-striping)

### DTrace

`* `[`DTrace`](http://dtrace.org/blogs/about/)\
`* `[`illumos`` ``Dynamic`` ``Tracing`` ``Guide`](http://dtrace.org/guide/preface.html)\
`* `[`USE`` ``Method:`` ``illumos`` ``Performance`` ``Checklist`](http://dtrace.org/blogs/brendan/2012/03/01/the-use-method-solaris-performance-checklist/)` - for administrators of physical systems / global zones`\
`* `[`USE`` ``Method:`` ``SmartOS`` ``Performance`` ``Checklist`](http://dtrace.org/blogs/brendan/2012/12/19/the-use-method-smartos-performance-checklist/)` - for users of non-global zones (except for sm-* utilities, these work on OmniOS)`\
`* `[`kdavyd`` ``/`` ``dtrace`](https://github.com/kdavyd/dtrace)` - Utilities for troubleshooting storage systems`

#### DTrace USDT

USDT probes are Userland Statically-Defined Tracing probes added to
application or language runtimes that provide additional probes beyond
what can be obtained from dynamic tracing of library and system calls.
This allows for deeper introspection and tracing of a broader set of
operations within the runtime.

[USDT probe
how-to](http://dtrace.org/blogs/dap/2011/12/13/usdt-providers-redux/)

DTrace probes are available for many common applications and languages,
including:

`* Apache: via `[`mod_usdt`](https://github.com/davepacheco/mod_usdt)` or `[`patches`](https://github.com/omniti-labs/omnios-build/tree/omniti-ms/build/apache22/patches)\
`* `[`Erlang/OTP`](http://www.erlang.org/doc/apps/runtime_tools/DTRACE.html)\
`* `[`Java`](http://docs.oracle.com/javase/6/docs/technotes/guides/vm/dtrace.html)\
`* `[`MySQL`](http://dev.mysql.com/tech-resources/articles/getting_started_dtrace_saha.html)\
`* `[`Node.js`](http://blog.nodejs.org/2012/04/25/profiling-node-js/)\
`* Perl: `[`in`` ``perl`` ``itself`](http://perldoc.perl.org/perldtrace.html)` or `[`in`` ``your`` ``program`` ``with`` ``Devel::DTrace::Provider`](http://search.cpan.org/~chrisa/Devel-DTrace-Provider-1.11/lib/Devel/DTrace/Provider.pm)\
`* `[`PHP`](http://pecl.php.net/package/DTrace)\
`* `[`PostgreSQL`](https://wiki.postgresql.org/wiki/DTrace)\
`* `[`Python`](https://pypi.python.org/pypi/python-dtrace)\
`* `[`Rails`](https://github.com/sax/rails-dtrace)\
`* `[`Ruby`](https://github.com/chrisa/ruby-dtrace)\
`* `[`Tcl`](http://wiki.tcl.tk/19923)

### IPS/pkg(5)

`* `[`Introduction`` ``to`` ``IPS`](http://www.slideshare.net/esproul/ips-image-packaging-system)` (slide stack, also available in `[`PDF`](http://omnios.omniti.com/media/IPS_Intro.pdf)`)`\
`* `[`pkg(5):`` ``Image`` ``Packaging`` ``System`](http://en.wikipedia.org/wiki/Image_Packaging_System)\
`* `[`Packaging`` ``and`` ``Delivering`` ``Software`` ``with`` ``the`` ``Image`` ``Packaging`` ``System:`` ``A`` ``Developer's`` ``Guide`](http://omnios.omniti.com/media/ipsdevguide.pdf)\
`* `[`IPS`` ``Project`` ``at`` ``java.net`](https://java.net/projects/ips)
