SUMMARY = "Install specific Variscite base files"
LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "\
    file://var-expand-partition.sh \
    file://var-expand-partition.service \
    file://var-fw-env-autofix.sh \
    file://var-fw-env-autofix.service \
"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = " \
    var-expand-partition.service \
    var-fw-env-autofix.service \
"

do_install () {
	install -Dm 0755 ${S}/var-expand-partition.sh ${D}${bindir}/var-expand-partition.sh
        install -Dm 0644 ${S}/var-expand-partition.service ${D}${systemd_unitdir}/system/var-expand-partition.service
	install -Dm 0755 ${S}/var-fw-env-autofix.sh ${D}${bindir}/var-fw-env-autofix.sh
        install -Dm 0644 ${S}/var-fw-env-autofix.service ${D}${systemd_unitdir}/system/var-fw-env-autofix.service
}

FILES:${PN} = "\
    ${bindir}/var-expand-partition.sh \
    ${bindir}/var-fw-env-autofix.sh \
    ${systemd_unitdir}/system/var-expand-partition.service \
    ${systemd_unitdir}/system/var-fw-env-autofix.service \
"

RDEPENDS:${PN} = "\
    e2fsprogs-resize2fs \
    parted \
"

COMPATIBLE_MACHINE = "(mx8-nxp-bsp|mx9-nxp-bsp|am62x-var-som|am62px-var-som)"
