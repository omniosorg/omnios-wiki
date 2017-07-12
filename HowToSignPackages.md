Signing Packages
================

This document specifies the process (but not the implementation
specifics) that OmniTI uses for creating signed packages, so that
interested third parties can sign their packages as well. The process is
straightforward, but requires the administrator to be familiar with how
SSL and IPS work. The \[wiki:Packaging\#How-tos packaging how-to
documents\] will be quite helpful here.

Prerequisites
-------------

` * A functioning IPS repository`\
` * An SSL CA and certificate with which to sign the packages (lots of docs on the internet for this, and you may have local site policies to adhere to as well that we can't cover here)`

Method
------

` 1. Create a repo and publish some packages to it.`\
` 1. Create an SSL CA and obtain its certificate and key. Alternately, use an existing one.`\
``  1. Obtain the list of packages, in FMRI form, to sign (one way to do this is, e.g., `pkg info -r -g $REPO_URL 'pkg:/*@*-0.151008' | grep FMRI | awk '{ print $2 }' > ~/fmris_to_sign_151008`, which will write all the FMRIs to sign for the 151008 release to the file `fmris_to_sign_151008`. ``\
` 1. Sign the packages with something like`

Known issues / troubleshooting
------------------------------

TBD
