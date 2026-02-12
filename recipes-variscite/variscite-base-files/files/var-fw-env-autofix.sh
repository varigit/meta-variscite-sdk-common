#!/bin/sh
set -eu

MARKER=/var/lib/fw-env-autofix.done
CFG=/etc/fw_env.config
TMP=/tmp/fw_env.config.$$

mark_done() {
  mkdir -p /var/lib
  : > "$MARKER"
}

# Run only once
[ -e "$MARKER" ] && exit 0

# Get the source device mounted as "/" (e.g. /dev/mmcblk0p2)
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

# Current device in fw_env.config (first field of first /dev/mmcblk line)
CUR="$(grep -v '^[[:space:]]*#' "$CFG" | grep '^/dev/mmcblk' | sed -n '1{s/[[:space:]].*$//;p;}')"

# If no mmc entry found, bail to avoid corrupting the config
if [ -z "$CUR" ]; then
  logger -t var-fw-env-autofix "no /dev/mmcblk entry in $CFG; skipping"
  mark_done
  exit 0
fi

# Update only if needed (preserve offset/size)
if [ "$CUR" != "$BASE" ]; then
  sed "s|^$CUR\([[:space:]]\)|$BASE\1|" "$CFG" > "$TMP"
  mv "$TMP" "$CFG"
fi

# Mark as done
mark_done
