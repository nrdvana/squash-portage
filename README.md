squash-portage
==============

Script to generate squashfs files for the Gentoo portage tree.

Gentoo portage consists of lots (too many) small files, and often occupies
more than 500MB of disk space.  A much preferable way to store and use it
is with a squashfs image (50MB).  Once you have the squashfs image, use this
script to update it.

While you can simply download a new portage tarball, unpack it, and run
squashfs on it, that takes a lot of time.  This is a script that mounts
your existing squashfs file, uses overlayfs to mount a tmpfs overtop it,
runs emerge --sync to freshen the tree, then runs squashfs on the result,
names it with a date, then unmounts the temporary stuff and mounts your new
portage image.

It runs very very fast, since all changes by rsync are written to memory, and
only the new files (according to the file timestamps in the squashfs image)
are transferred.  The best of all worlds.  Combine with a SSD for lightning-fast
portage updates.

Prerequisites
=============

You need your /usr/portage to be read-only, so set the following variables
in /etc/portage/make.conf:

    DISTDIR=/var/portage/distfiles
    PKGDIR=/var/portage/packages
    RPMDIR=/var/portage/rpm

(and of course, create those directories)

Next, for this script, you need overlayfs or unionfs.  These are available
on many distros, but not included in the mainline kernel (until overlayfs
in 3.11)

Overrlayfs
==========

This can be hard to find, sometimes (until it is mainlined)

For Linux 3.10, this one works:
    https://dev.openwrt.org/browser/trunk/target/linux/generic/patches-3.10?rev=37116
