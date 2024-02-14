FILESEXTRAPATHS:prepend:var-som := "${THISDIR}/${PN}:"

# Substitute build year in issue files
ISSUE_RELEASE_YEAR="${@d.getVar('DATE')[:4]}"

do_configure:append() {
    for file in "issue issue.net"; do
        sed -i "s/@@ISSUE_RELEASE_YEAR@@/${ISSUE_RELEASE_YEAR}/" ${WORKDIR}/${file}
    done
}
