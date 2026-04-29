# Force nobranch to fix renamed default branches for particular recipes
INHERIT += "srcuri-force-nobranch"

SRCURI_FORCE_NOBRANCH_LIST ??= " \
    bmap-tools https://github.com/intel/bmap-tools \n \
    mobile-broadband-provider-info https://gitlab.gnome.org/GNOME/mobile-broadband-provider-info \n \
"
