Man Page Sections
=================

If you're from a BSD and/or Linux background, you'll notice that the
location of man pages in OmniOS is slightly different. OmniOS, being a
distribution of [illumos](http://illumos.org), itself a descendant of
Solaris, uses the System V man sections. For each section, there is an
*intro* man page that describes that section, and the online equivalent
has been linked to each description below.

The table below illustrates the SysV sections and maps them (roughly) to
their BSD/Linux equivalents.

| Section | Description                                                          | BSD/Linux Section | 
|---------|----------------------------------------------------------------------|-------------------|
| 1       | [User Commands](http://illumos.org/man/1/intro)                      | 1                 | 
| 1M      | [System Administration Commands](http://illumos.org/man/1M/intro)    | 8                 |
| 2       | [System Calls](http://illumos.org/man/2/intro)                       | 2                 |
| 3       | [Library Functions](http://illumos.org/man/3/intro)                  | 3                 |
| 4       | [File Formats and Configurations](http://illumos.org/man/4/intro)    | 5                 |
| 5       | [Standards, Environments and Macros](http://illumos.org/man/5/intro) | 7                 |
| 7       | [Device and Network Interfaces](http://illumos.org/man/7/intro)      | 4                 |
| 9       | [Kernel routines](http://illumos.org/man/9/intro)                    |                   |

Some sections break down further into subsections, such as “3C” for C
library functions or “7D” for device drivers. These are explained in
their respective intro pages.

Note:

> In addition to the -s flag for specifying the desired
> section, you can also append a dot, followed by the section number, to
> the command being searched. For example, `man -s 2 intro` is
> equivalent to `man intro.2`