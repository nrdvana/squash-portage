SQUASHFS_DIR=/usr
dt=`date +%Y%m%d`

die() {
	echo "Script failed: $@";
	umount /var/tmp/oldportage 2>/dev/null;
	umount /var/tmp/newportage 2>/dev/null;
	exit 1;
}

umount /var/tmp/oldportage 2>/dev/null
umount /var/tmp/newportage 2>/dev/null
rm -rf /var/tmp/newportage
mkdir -p /var/tmp/newportage /var/tmp/oldportage

if [ -e "$SQUASHFS_DIR/portage.sqsh" ]; then
	mount "$SQUASHFS_DIR/portage.sqsh" /var/tmp/oldportage || die "Can't mount portage squashfile at /var/tmp/oldportage";
else
	echo "Warning: no $SQUASHFS_DIR/portage.sqsh, using current /usr/portage as-is.";
	mount --bind /usr/portage /var/tmp/oldportage || die "Can't bind-mount /usr/portage to /var/tmp/oldportage";
fi

if grep unionfs /proc/filesystems >/dev/null; then
	mount -t unionfs -o dirs=/var/tmp/newportage=rw:/usr/portage=ro none /usr/portage || die "Can't create overlay on /usr/portage";
elif grep overlayfs /proc/filesystems >/dev/null; then
	mount -t overlayfs -o lowerdir=/var/tmp/oldportage,upperdir=/var/tmp/newportage none /usr/portage || die "Can't create overlay on /usr/portage";
else
	die "Require unionfs or overlayfs, and neither listed in /proc/filesystems";
fi

emerge --sync || die "Emerge --sync failed";

if [ -f "$SQUASHFS_DIR/portage-${dt}.sqsh" ]; then
	echo "Warning: $SQUASHFS_DIR/portage-${dt}.sqsh already exists!";
	mv "$SQUASHFS_DIR/portage-${dt}.sqsh" "$SQUASHFS_DIR/portage-${dt}.sqsh.old" || die "Failed to move $SQUASHFS_DIR/portage-${dt}.sqsh";
	echo "Moved to $SQUASHFS_DIR/portage-${dt}.sqsh.old";
fi
mksquashfs /usr/portage "$SQUASHFS_DIR/portage-${dt}.sqsh" || die "mksquashfs failed";
chmod 444 "$SQUASHFS_DIR/portage-${dt}.sqsh"
ln -sf "portage-${dt}.sqsh" "$SQUASHFS_DIR/portage.sqsh" || die "Can't create symlink for portage.sqsh";

umount /usr/portage || die "Can't unmount /usr/portage";
umount /var/tmp/oldportage || die "Can't unmount /var/tmp/oldportage";
rm -rf /var/tmp/newportage /var/tmp/oldportage || die "Can't clean up /var/tmp/*portage"

mount "$SQUASHFS_DIR/portage.sqsh" /usr/portage || die "Can't mount new portage.sqsh"

