#!/bin/sh
set -eu

# Detect root partition (e.g., /dev/mmcblk1p2)
ROOT_PART=$(findmnt -n -o SOURCE /)

# Extract DISK_BASE and PART_NUM
case "$ROOT_PART" in
    /dev/mmcblk*p[0-9]*)
        DISK_BASE=${ROOT_PART%p[0-9]*}
        PART_NUM=${ROOT_PART##*p}
        ;;
    *)
        echo "Unsupported root device format: $ROOT_PART"
        exit 1
        ;;
esac

# Get all partition numbers from the disk table.
set -- $(parted -m -s "$DISK_BASE" print | sed -n 's/^\([0-9][0-9]*\):.*/\1/p')

PART_COUNT=$#
LAST_PART_NUM=

for part in "$@"; do
    LAST_PART_NUM=$part
done

TARGET_PART=$ROOT_PART
TARGET_PART_NUM=$PART_NUM

# If the root partition is not the only partition on disk, grow the last one.
if [ "$PART_COUNT" -ne 1 ]; then
    TARGET_PART="${DISK_BASE}p${LAST_PART_NUM}"
    TARGET_PART_NUM=$LAST_PART_NUM
fi

# Resize the partition to use 100% of the disk
parted -s "$DISK_BASE" resizepart "$TARGET_PART_NUM" 100%

# Resize the filesystem (assumes ext4)
resize2fs "$TARGET_PART"
