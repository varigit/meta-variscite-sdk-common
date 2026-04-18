#!/bin/sh
set -eu

MARKER=/var/lib/fw-env-autofix.done
CFG=/etc/fw_env.config
TMP=/tmp/fw_env.config.$$
UBOOT_ENV_LINK=/etc/u-boot-initial-env

mark_done() {
  mkdir -p /var/lib
  : > "$MARKER"
}

# Switch /etc/u-boot-initial-env to the MMC default environment when booting from eMMC/uSD.
set_initial_env_link() {
  env_name="u-boot-initial-env-sd"

  [ -L "$UBOOT_ENV_LINK" ] || return 0
  [ -e "/etc/${env_name}" ] || return 0

  current_target="$(readlink "$UBOOT_ENV_LINK" || true)"
  if [ "$current_target" != "$env_name" ]; then
    ln -snf "$env_name" "$UBOOT_ENV_LINK"
  fi
}

# Detect the MX6 hybrid layout where U-Boot env stays in NAND while rootfs is on eMMC.
mx6_nand_env_with_emmc_rootfs() {
  # "[ ... ] || return 1" means: if BASE is not /dev/mmcblk0, stop here and report "false".
  [ "$BASE" = "/dev/mmcblk0" ] || return 1
  # "$( ... )" captures the command output; this test is true only when rootfs_device is exactly "emmc".
  [ "$(fw_printenv -n rootfs_device 2>/dev/null || true)" = "emmc" ]
}

# Run only once
[ -e "$MARKER" ] && exit 0

# Get the source device mounted as "/" (e.g. /dev/mmcblk0p2)
# Use sed to extract the first field of the "mount" line for "/", e.g. /dev/mmcblk0p2 or ubi0:rootfs.
SRC="$(mount | sed -n 's/^\([^[:space:]]*\) on \/ .*/\1/p' | sed -n '1p')"

# Convert partition -> base disk (e.g. /dev/mmcblk0p2 -> /dev/mmcblk0)
BASE="${SRC%p[0-9]*}"

# If "/" is not on an mmcblk device (e.g. /dev/root, overlay), bail
case "$BASE" in
  /dev/mmcblk*) : ;;
  *)
    logger -t var-fw-env-autofix "root source '$SRC' not mmcblk; skipping"
    mark_done
    exit 0
    ;;
esac

if mx6_nand_env_with_emmc_rootfs; then
  logger -t var-fw-env-autofix "detected MX6 NAND environment with eMMC rootfs; keeping defaults"
  mark_done
  exit 0
fi

# Read the MMC device currently present in fw_env.config, even if that line is commented out.
CUR="$(sed -n 's/^[[:space:]]*#\{0,1\}[[:space:]]*\(\/dev\/mmcblk[0-9][0-9]*\)[[:space:]].*$/\1/p' "$CFG" | sed -n '1p')"

# If no mmc entry found, bail to avoid corrupting the config
if [ -z "$CUR" ]; then
  logger -t var-fw-env-autofix "no /dev/mmcblk entry in $CFG; skipping"
  mark_done
  exit 0
fi

# Rewrite fw_env.config only when the selected MMC device differs or NAND is still enabled.
# Preserve offset and size fields
if [ "$CUR" != "$BASE" ] || grep -q '^[[:space:]]*/dev/mtd' "$CFG"; then
  # First sed command comments active /dev/mtd lines; second one enables the /dev/mmcblkX line and replaces its device name with $BASE.
  sed \
    -e '/^[[:space:]]*\/dev\/mtd/s/^/#/' \
    -e "s|^[[:space:]]*#\\{0,1\\}[[:space:]]*/dev/mmcblk[0-9][0-9]*|$BASE|" \
    "$CFG" > "$TMP"
  mv "$TMP" "$CFG"
fi

set_initial_env_link

# Mark as done
mark_done
