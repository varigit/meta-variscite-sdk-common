# Work around fmtlib/fmt moving its default branch from master to main.
# Submitted to meta-oe:
# https://lists.openembedded.org/g/openembedded-devel/message/126832
SRC_URI:remove = "git://github.com/fmtlib/fmt;branch=master;protocol=https"
SRC_URI:prepend = "git://github.com/fmtlib/fmt;branch=main;protocol=https "
