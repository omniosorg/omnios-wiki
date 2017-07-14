Packaging
---------

See [GeneralAdministration](GeneralAdministration.md#ConfigurePublishers)
for how to manage repositories.

OmniOS takes a “layer cake” approach to packaging. The core OS contains
the packages needed to build the OS, plus a few small frills (more
shells, tmux/screen, etc.) Users are encouraged to either create their
own package repos for additional software they want to run (and where
they like it to be installed) or use repos published by other users.

Maintainers of add-on repos are encouraged to share their work with the
community. If you wish to have your repo listed here, please speak up on
the [mailing
list](http://lists.omniti.com/mailman/listinfo/omnios-discuss) or
[IRC](irc://chat.freenode.net/omnios).

## Repos

| URL                                      | Publisher | Build Scripts                                                     | Notes                                       |
|------------------------------------------|-----------|-------------------------------------------------------------------|---------------------------------------------|
| <https://pkg.omniosce.org/r151022/core/> | omnios    | [r151022](https://github.com/omniosorg/omnios-build/tree/r151022) | Core OS components (current LTS and Stable) |
| <https://pkg.omniosce.org/bloody/core/>  | omnios    | [master](https://github.com/omniosorg/omnios-build)               | Core OS components (unstable)               |

### Unofficial Extras

| URL                                      | Publisher          | Maintainer                             | Build Scripts                                                               | Notes                                                                        |
|------------------------------------------|--------------------|----------------------------------------|-----------------------------------------------------------------------------|------------------------------------------------------------------------------|
| <http://pkg.cs.umd.edu/>                 | cs.umd.edu         | Sergey Ivanov                          |                                                                             |                                                                              |
| <http://pkg.omniti.com/omniti-ms/>       | ms.omniti.com      | OmniTI                                 | [omniti-ms](https://github.com/omniti-labs/omniti-ms)                       | Non-core packages used in OmniTI's managed services environments             |
| <http://pkg.omniti.com/omniti-perl/>     | perl.omniti.com    | OmniTI                                 | [omnios-build-perl](https://github.com/omniti-labs/omnios-build-perl)       | Perl module dists designed to work with omniti/runtime/perl                  |
| <http://pkg.niksula.hut.fi/>             | niksula.hut.fi     | pkg@niksula.hut.fi                     | <https://github.com/niksula/omnios-build>                                   | Signed packages; see the [instructions](http://pkg.niksula.hut.fi/)          |
| <http://scott.mathematik.uni-ulm.de/>    | uulm.mawi          | Steffen Kram                           | [stefri/omnios-build](https://github.com/stefri/omnios-build)               |                                                                              |
| <http://sfe.opencsw.org/localhostomnios> | localhostomnios    | SFE Community                          | <https://sourceforge.net/p/pkgbuild/code/HEAD/tree/spec-files-extra/trunk/> | Open for contribution                                                        |
| <https://ips.qutic.com/>                 | application        | [qutic development](https://qutic.com) | <https://github.com/jfqd/omnios-userland>                                   | Userland packages; pull requests welcome                                     |          
| DEPRECATED                               | omnios.blackdot.be | Jorge Schrauwen                        | [omnios-build-blackdot](https://github.com/sjorge/omnios-build-blackdot)    | source still available on github                                             |
| <http://www.opencsw.org/>                | SysV packages      | OpenCSW                                | <https://sourceforge.net/p/gar/code/HEAD/tree/>                             | A collection of SysV packages (i.e. for use with the old pkgadd(1M) command) |

Note that ms.omniti.com and perl.omniti.com hold packages built
specifically for OmniTI's own use. While there is nothing secret or
astonishing therein, non-OmniTI users may wish to see the
[template branch](https://github.com/omniti-labs/omnios-build/tree/template)
which may be used as the basis to build one's own packages.

## How-to's

* [Creating IPS Repositories](CreatingRepos.md) - Everything Lives in a Repo so here is how to create one
* [Populating IPS Repositories](PopulatingRepos.m) - How to get all those wonderful packages into our repos
* [PackagingForOmniOS](PackagingForOmniOS.md) - How to create packages to put in the repos you've set up above
* [FetchIPSFilesWithoutPkg](FetchIPSFilesWithoutPkg.md) - Fetching files from an IPS repo without pkg(1)
