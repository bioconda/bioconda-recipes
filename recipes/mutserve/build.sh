#!/bin/bash

# Set variables
MUTSERVE_DATA="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$MUTSERVE_DATA" ] || mkdir -p "$MUTSERVE_DATA"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"


# Copy scripts
cp rCRS* ${MUTSERVE_DATA}/
cp mutserv* ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/mutserve


# set MUTSERVE_DATA variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/mutserve.sh
export MUTSERVE_DATA=${MUTSERVE_DATA}/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/mutserve.sh
unset MUTSERVE_DATA
EOF
