#!/bin/bash

# Copy metaWEPP files to $PREFIX/metaWEPP
mkdir -p ${PREFIX}/metaWEPP
cp -rf "${SRC_DIR}/Snakefile" "${SRC_DIR}/scripts" "${SRC_DIR}/config" "${SRC_DIR}/data" "${SRC_DIR}/LICENSE" "${PREFIX}/metaWEPP/"

# Ensure the bin directory exists
mkdir -p "${PREFIX}/bin"

# Create the wrapper script
cat <<WRAPPER > "${PREFIX}/bin/run-metawepp"
#!/bin/bash
exec snakemake -s "\${CONDA_PREFIX}/metaWEPP/Snakefile" "\$@"
WRAPPER

# Make the wrapper executable
chmod +x "${PREFIX}/bin/run-metawepp"
