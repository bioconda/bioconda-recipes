#!/bin/bash

SHARE_DIR="$PREFIX"/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
PLUGIN_DIR="$SHARE_DIR"/plugin
MKVTREESMAPDIR="$SHARE_DIR"/TRANS/

# Create activate script
mkdir -p ${PREFIX}/etc/conda/activate.d
ACTIVATE_SCRIPT=${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}.sh
# SAVE_VARIABLE_NAME=LD_LIBRARY_PATH_BEFORE_${PKG_NAME}_${PKG_VERSION}_${PKG_BUILDNUM}
# SAVE_VARIABLE_NAME=${SAVE_VARIABLE_NAME//./_}
SAVE_VARIABLE_NAME=LD_LIBRARY_PATH_BEFORE_${PKG_NAME} # Should be enough
echo "# Activate script for ${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
# Save LD_LIBRARY_PATH
export ${SAVE_VARIABLE_NAME}=\${LD_LIBRARY_PATH}
# Modify it
export LD_LIBRARY_PATH=${PLUGIN_DIR}:\${LD_LIBRARY_PATH}
# Export MKVTREESMAPDIR
export MKVTREESMAPDIR=${MKVTREESMAPDIR}
" > ${ACTIVATE_SCRIPT}

# Create deactivate script
mkdir -p ${PREFIX}/etc/conda/deactivate.d
DEACTIVATE_SCRIPT=${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}.sh
echo "# Dectivate script for ${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
# Restore LD_LIBRARY_PATH
export LD_LIBRARY_PATH=\${${SAVE_VARIABLE_NAME}}
# Remove MKVTREESMAPDIR
unset MKVTREESMAPDIR
# Remore ${SAVE_VARIABLE_NAME}
unset ${SAVE_VARIABLE_NAME}
" > ${DEACTIVATE_SCRIPT}

echo "Selection functions are installed in ${PLUGIN_DIR}.
Symbol map files are installed in ${MKVTREESMAPDIR}.
Activation and deactivation scripts will set LD_LIBRARY_PATH and MKVTREESMAPDIR accordingly
so you can use selection functions and symbol map files without specifying their full path.
Those scripts are in ${ACTIVATE_SCRIPT} and ${DEACTIVATE_SCRIPT} respectively.
" > $PREFIX/.messages.txt
