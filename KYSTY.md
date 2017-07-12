The OmniOS Approach to Software Distribution
============================================

OmniOS embodies a philosophy we've dubbed KYSTY, for Keep Your
!{Shit|Stuff|Software} To Yourself. Every OS requires a collection of
third-party libraries and utilities to run itself. Applications need
third-party libraries and supporting utilities too. However, **the two
need not be the same.**

I'll Use Mine, You Use Yours
----------------------------

In many other systems, there is a single version of a given library or
language runtime that is used both by components of the system itself
and by users of the system for their own applications. On the kind of
time scales that enterprise OS support covers, large changes can occur
in a given piece of software. A new library version might come out that
offers desirable features not available in the version shipped with the
OS. The new version may also break backward compatibility with existing
applications. If that application happens to be a core component of the
OS, then upgrading the library becomes much more difficult, if not
impossible.

KYSTY is, above all else, about separating as much as possible the
spheres of responsibility for the OS itself and the application
environment. The two necessarily have very different goals and
development timelines.

This Is Nothing New
-------------------

It is true that there have long been, on other OSes, alternative or
add-on repos full of packages, but OmniOS embraces KYSTY as a core
organizing principle. We purposefully ship only what we need to build
and run the OS. In many cases, these are not the most recent versions.
Except in the most basic circumstance, you should not use these things
in your app stack. At best, their versions are stagnant; at worst, they
may go away entirely as the OS components they exist for are rewritten
or removed. For example, [intrd(1M)](http://illumos.org/man/1m/intrd) is
currently a Perl script. It is being [rewritten in
C](http://cr.illumos.org/~webrev/0xffea/intrd-gsoc-01/), so that's one
less Perl dependency.

But This Is Really Inconvenient!
--------------------------------

It's true, building (and maintaining) your own software stack is a lot
of work. The payoff is that your application stack is truly yours.
You're not at the mercy of someone else's idea of what the version of X
should be, what plugins or modules are available, where things live,
etc. You also have the power to make changes according to your own
schedule, without waiting for someone else to provide you an update.

You might not care enough about the particular build options and just
want something you can install and use. That's fine. Find someone else
who has done the work and made their packages available via their own
publisher. OmniOS encourages a “layer cake” approach to the packaging
ecosystem. \[wiki:Packaging Add packages from different collections\] to
your system to get the tools you want.
