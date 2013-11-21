# squash-portage

## Overview

Script to generate squashfs files for the Gentoo portage tree.

Gentoo portage consists of lots (too many) small files, and often occupies
more than 500MB of disk space.  A much preferable way to store and use it
is with a squashfs image (50MB).  Use this script to create and "emerge --sync"
the squashfs file.

## Description

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

## Prerequisites

  * Overlayfs or Unionfs
  * An existing /usr/portage directory
  * All writable portions of portage relocated outside that tree

For this script, you need overlayfs or unionfs support inn your kernel.
These are available on many distros, but not included in the mainline
kernel until overlayfs in 3.11

If you don't have a /usr/portage, download one like normal for gentoo.

If your /usr/portage still has distfiles, packages, or rpm directories,
set the following variables in /etc/portage/make.conf:

    DISTDIR=/var/portage/distfiles
    PKGDIR=/var/portage/packages
    RPMDIR=/var/portage/rpm

(and of course, create those directories)

I recommend also setting

    PORTAGE_RSYNC_EXTRA_OPTS="--exclude ChangeLog --delete-excluded"

because who actually cares about the changelog?  If you want to read it you
can read it online.  Saves a ton of space and bandwidth.

Finally, this script writes the new portage.sqsh files to /usr.  You might
not like this location.  Simply edit the first line of the script.  Also, the
script re-mounts /usr/portage for you.  If this was your first time making a
squash file, you probably want to

    umount /usr/portage
    rm -rf /usr/portage/*
    mount /usr/portage.sqsh /usr/portage

to reclaim disk space.

## Overrlayfs

This can be hard to find, sometimes (until it is mainlined)

For Linux 3.10, this one works:
    https://dev.openwrt.org/browser/trunk/target/linux/generic/patches-3.10?rev=37116
