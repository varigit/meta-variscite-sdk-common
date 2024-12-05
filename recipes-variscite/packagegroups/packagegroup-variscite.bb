SUMMARY = "Variscite Common Package Group"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = " \
    ${PN}-devel \
    ${PN}-swupdate \
"

RDEPENDS:${PN}-devel = " \
    bluealsa \
    devmem2 \
    expect \
    gptfdisk \
    hostapd \
    hdparm \
    iperf3 \
    iptables \
    iw \
    kmod \
    libgpiod \
    libgpiod-tools \
    nodejs \
    openssh-sftp-server \
    rng-tools \
    screen \
    sudo \
    tcf-agent \
    var-mii \
    wpa-supplicant \
    wireless-regdb-static \
    zstd \
"

# Only for DRM enabled machines
RDEPENDS:${PN}-devel:append:imxdrm = " \
    libdrm-tests \
"

RDEPENDS:${PN}-swupdate = "\
    swupdate \
    swupdate-www \
"
