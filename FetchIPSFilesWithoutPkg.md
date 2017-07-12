Fetching IPS Package Files Without pkg(1)
=========================================

Inspired by Gavin Sandie's work on [PXE-booting OmniOS from
Debian](https://gist.github.com/3874066) I wondered how one might fetch
files from an IPS repo without having access to the pkg(1) client.

I snooped a pkg transaction from an OmniOS system and while this method
might not be fool-proof, it's close.

The first thing to understand about IPS is that it's a very
network-centric packaging system, so there isn't a single-file blob
containing all the package's files. They are instead ingested into a
hashed directory structure and referred to by a metadata document called
a manifest. The pkg(1) client fetches and reads this manifest to
understand how the package should be installed, then fetches the
individual file resources (if any) via HTTP and places them on the
system.

Let's say I want to fetch “miniroot.gz” from the package
“system/install/kayak-kernel”. I first get the manifest, which I can
find in the pkg server's catalog. For example, the OmniOS unstable
repo's catalog is at
<http://pkg.omniti.com/omnios/bloody/en/catalog.shtml> . There I find
the kayak-kernel package and view the manifest by clicking the
“Manifest” link in the right-most column.

<http://pkg.omniti.com/omnios/bloody/manifest/0/system%2Finstall%2Fkayak-kernel%401.0%2C5.11-0.151002%3A20120425T165157Z>

That document describes the kayak-kernel package. Important for this
discussion are the “file” actions. Actions express the content of the
package and the properties of those contents. Here's the line that
describes the miniroot.gz file. I've broken up the line for readability.

The first value after the “file” action declaration is the filename of
this resource on the pkg server. When a package is published to a
server, all files are named by the SHA-1 hash of their content:

Files are stored in a hashed directory structure in the on-disk repo:

All files are stored in gzipped form as well, and that's what the
pkg.csize and pkg.size attributes indicate (compressed vs. actual size).
In this case, the file is already gzipped, so it doesn't compress much
more.

Here's where I had to snoop an actual transaction because there is not a
direct mapping from the URI of this file to the hashed directory
structure. The pkg.depotd process (a simple Python-based webserver)
handles the translation and knows where to fetch files from disk.

By locating the file's hash name in the packet payload (the HTTP
request) I could see that the URI was

 is the mapping from our front-end Apache proxy. pkg.depotd doesn't have
any sort of access control, so we put Apache in front of it to limit the
allowed HTTP methods to HEAD and GET. Otherwise, anyone with network
access could publish to our repo. The next “omnios” is the publisher
name, which you can get from the first component of the FMRI (pkg.fmri
in the first line of the manifest). Then, followed by the file hash that
we found in the manifest.

Note: &gt; The URL component following file requests is “1”, which is
the version of the pkg(5) API for file actions that the client is
requesting. For other types of resources the number may be different,
but in OmniOS, is either 0 or 1.

Now that we know what to request, we can grab just the file we want:

I now have the exact file as was installed by pkg(1). This is useful,
for example, if you're setting up PXE booting for OmniOS installs on a
non-OmniOS system. Ordinarily you'd need an OmniOS system to either
fetch the files via 'pkg install' or by building the miniroot and other
bits from the Kayak source.

A sufficiently motivated person could probably automate this too. :)
