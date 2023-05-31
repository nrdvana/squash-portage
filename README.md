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

  * Kernel support for Squashfs, and Overlayfs or Unionfs
  * An existing /var/db/repos/gentoo directory
  * All writable portions of portage relocated outside that tree
    (which is now the default for gentoo)

### Squashfs

This is a filesystem that acts like a mountable .tar.gz file.  A lot of distros
don't enable it by default, but you should always fix that! because it's an
awesome tool to have handy.

### Overlayfs (or Unionfs)

Any modern Linux distro (since 3.18) supports overlayfs.  Unionfs was needed
before that, and I haven't tested unionfs support in a long time, but it's
still in the script.

### Setting-up Read-Only Portage

Follow the gentoo handbook to get your first portage snapshot (currently at
/var/db/repos/gentoo)

If you still use /usr/portage and it contains the directories for distfiles,
packages, or rpm directories, set the following variables in /etc/portage/make.conf:

    DISTDIR=/var/portage/distfiles
    PKGDIR=/var/portage/packages
    RPMDIR=/var/portage/rpm

(and of course, create those directories)

I also recommend setting

    PORTAGE_RSYNC_EXTRA_OPTS="--exclude ChangeLog* --delete-excluded"

because who actually cares about the changelog?  If you want to read it you
can read it online.  Saves a ton of space and bandwidth.

Also, you probably want it to auto-mount on boot.  Add this to /etc/fstab:

    # <fs>                      <mountpoint>          <type>    <opts>   <dump/pass>
    /var/db/repos/portage.sqsh  /var/db/repos/gentoo  squashfs  loop,ro  0 0

Finally, this script writes the new portage.sqsh files to /var/db/repos.  You might
not like this location.  Simply edit the first line of the script.  Also, the
script re-mounts /var/db/repos/gentoo for you.  If this was your first time making a
squash file, you probably want to

    umount /var/db/repos/gentoo
    rm -rf /var/db/repos/gentoo/*
    mount /var/db/repos/portage.sqsh /var/db/repos/gentoo

to reclaim disk space.
