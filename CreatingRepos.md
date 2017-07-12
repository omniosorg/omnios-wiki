Creating Repos
--------------

Why? Because it's easy. It's also a good way to separate packages with
different dispositions, such as core OS vs. site-specific.

First, create the repo. Any directory will do, but it's usually a good
idea to make a filesystem for your repo, which is trivial with ZFS but
it can be UFS or NFS just as easily.

The last command sets the default publisher to be “myrepo.example.com”.
A *publisher* is an entity that builds packages. Publishers are named
for uniqueness among a list of possible software providers. Using
Internet domain-style names or registered trademarks provides a natural
namespace.

At this point there is a fully-functioning pkg repository at . The local
machine can use this repository, but it's more likely that you'll want
other machines to be able to access this repo.

Configure pkg.depotd to provide remote access. pkg.depotd provides an
HTTP interface to a pkg repo. Here we are going to make the repo server
listen on port 10000, and use the repo dir we created as its default.

### Additional Depot Servers

To create a additional depot servers, create a new instance of the
pkg/server service for each repository you wish to serve. You'll need to
change the filesystem path to the root of the repository, and optionally
the port to listen on and whether to allow publishing.

There is now a depot server running at port 10003 that allows publishing
(the default is read-only). Note that pkg.depotd provides no
authentication, so you may wish to put a reverse-proxy server in front
of it if you are going to expose the service publicly. The proxy would
need to limit request methods to HEAD and GET for untrusted users.
