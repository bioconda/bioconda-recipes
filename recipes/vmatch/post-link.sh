#!/bin/bash

SHARE_DIR="$PREFIX"/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
MKVTREESMAPDIR="$SHARE_DIR"/TRANS/

# Create activate script
mkdir -p ${PREFIX}/etc/conda/activate.d
echo "# Activate script for ${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
# Export MKVTREESMAPDIR
export MKVTREESMAPDIR=${MKVTREESMAPDIR}
" > ${ACTIVATE_SCRIPT}

# Create deactivate script
mkdir -p ${PREFIX}/etc/conda/deactivate.d
DEACTIVATE_SCRIPT=${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}.sh
echo "# Deactivate script for ${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
# Remove MKVTREESMAPDIR
unset MKVTREESMAPDIR
" > ${DEACTIVATE_SCRIPT}

# Write a message for the user
echo "
vmatch selection functions are installed in ${PREFIX}/lib.
You can use them without specifying their full path.
Symbol map files are installed in ${MKVTREESMAPDIR}.
Activation and deactivation scripts will set MKVTREESMAPDIR accordingly
so you can use symbol map files without specifying their full path.
Those scripts are in ${ACTIVATE_SCRIPT} and ${DEACTIVATE_SCRIPT} respectively.
" > $PREFIX/.messages.txt
