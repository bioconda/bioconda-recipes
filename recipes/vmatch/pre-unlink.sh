# Remove activate script
ACTIVATE_SCRIPT=${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}.sh
rm ${ACTIVATE_SCRIPT}

# Remove deactivate script
DEACTIVATE_SCRIPT=${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}.sh
rm ${DEACTIVATE_SCRIPT}
