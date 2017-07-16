Preparing Release Media
=======================

How to make the release images. If any of these are created, *all*
should be created so that we remain consistent.

## Kayak

Kayak builds require a global zone with no non-global zones configured.
As of [r151022](ReleaseNotes/r151022.md) Kayak now generates ALL of the
OmniOS release media.

Check out the [source]https://github.com/omniosorg/kayak), **ensuring
that it is the branch matching the release you're building for**,
install gnu-make, cdrtools, and if this isn't the first time you've make
Kayak media on this host:

```
# zfs destroy -R rpool/kayak_image
# zfs create rpool/kayak_image
```

Then (as root or with sudo):

```
# gmake install-usb
```

The install-usb target is dependent on all of the other media. When you
are done, you will see:

| file                                        | purpose                                                                                     |
|---------------------------------------------|---------------------------------------------------------------------------------------------|
| `/rpool/kayak_image/miniroot.gz`            | The PXE boot miniroot that also forms the ISO/USB miniroot                                  |
| `/rpool/kayak_image/kayak_$RELEASE.zfs.bz2` | The compressed ZFS send stream that Kayak installers spray onto a new rpool                 |
| `/rpool/kayak_image/$RELEASE.iso`           | The ISO image for the [Kayak Interactive Installer](KayakInteractive.md)                    |
| `/rpool/kayak_image/$RELEASE.usb-dd`        | The USB stick image (using dd(1) for the [Kayak Interactive Installer](KayakInteractive.md) |

## Publishing Media Files

Copy the media files to the `https://pkg.omniosce.org/` webserver, placing
them in the media directory. Don't forget to [update symlinks](WeeklyReleaseHowto.md#Updatingsymlinks).
