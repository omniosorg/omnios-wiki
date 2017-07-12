Populating IPS Repos
====================

So we have set up a fancy IPS repo, but now we need to get packages into
and out of it. We could either copy all the packages or only some of
them. In either case, the source and destination URIs may be any
combination of !http:// and !file:// URIs.

Wholesale Repo Copy
-------------------

What we have done above is tell pkgrecv to suck down all the packages
from pkg.omniti.com/omnios/release and push them into a local file-based
repo. The **!pkg:/\*** at the end is just saying get everything.

Cherry-picking
--------------

You could just put in a pattern to match if you wanted specific
packages.

Specify as many pkg: FMRIs as needed (you can use shell-style globbing
as in the wholesale example above.)

Changing Package Metadata
-------------------------

To pull down an individual package for editing, do something similar to
the following example. You may want to make a metadata change, such as
fixing a missing dependency, correcting a typo in the summary, or
changing the publisher name. The gist is that you pull down a copy of
the package to your local filesystem, make your changes, then publish an
updated package back to the original repo or maybe to a different repo.

&gt; Changing package metadata in this way will result in a new package
with a different timestamp from the source package.

`* Make a working directory somewhere`\
`  `\
`* Pull down a copy of the package to this directory.  Using --raw gets us the package metadata as well as the content, and treats the destination as a plain directory and not a repository.`\
`  `\
`* In your specified directory you'll end up with a subdirectory structure of package-name/version-string, e.g.`\
`  `\
`* Optionally make metadata changes.  In the version directory there is a file, `“`manifest`”`.  Make any necessary changes in this file.`\
`* Use pkgsend to publish the package to a repo.`\
`  `

Note that when opening a new repo transaction, the environment variable
PKG\_TRANS\_ID gets set by capturing the output of the 'pkgsend open'
operation, which returns a unique identifier for that transaction.
PKG\_TRANS\_ID must be set for the subsequent actions to succeed.

Notice as well that I didn't include the timestamp portion of the
existing package's FMRI. It's not needed; as you can see, the updated
package gets a new timestamp that corresponds to the publication date.
