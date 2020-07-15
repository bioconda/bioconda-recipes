#!/bin/bash

# Copy the jar.
SHARE_DIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p ${SHARE_DIR}
cp BMGE.jar ${SHARE_DIR}

# Alias the jar.
mkdir -p ${PREFIX}/bin/
cat <<EOF >> ${PREFIX}/bin/bmge
#! /bin/bash
exec java -Xmx128G -jar ${SHARE_DIR}/BMGE.jar \$@

EOF
chmod +x ${PREFIX}/bin/bmge
