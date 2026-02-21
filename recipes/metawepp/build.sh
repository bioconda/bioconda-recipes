#!/bin/bash

# Copy metaWEPP files to $PREFIX/metaWEPP
mkdir -p ${PREFIX}/metaWEPP
cp -rf "${SRC_DIR}"/* "${PREFIX}/metaWEPP"

# Creates a function 'run-metawepp' that injects the -s argument
ACTIVATE_DIR="${PREFIX}/etc/conda/activate.d"
DEACTIVATE_DIR="${PREFIX}/etc/conda/deactivate.d"
mkdir -p "${ACTIVATE_DIR}" "${DEACTIVATE_DIR}"

cat <<'EOF' > "${ACTIVATE_DIR}/z_{{ name|lower }}_activate.sh"
#!/bin/bash

run-metawepp() {
        # Calls the snakemake with correct Snakefile
        command snakemake -s "$CONDA_PREFIX/metaWEPP/Snakefile" "$@"
}
# Want this command available in sub-shells/scripts
export -f run-metawepp 2>/dev/null || true
EOF

# Removes the function when the user exits the environment
cat <<'EOF' > "${DEACTIVATE_DIR}/z_{{ name|lower }}_deactivate.sh"
#!/bin/bash
unset -f run-metawepp
EOF

chmod +x "${ACTIVATE_DIR}/z_{{ name|lower }}_activate.sh"
chmod +x "${DEACTIVATE_DIR}/z_{{ name|lower }}_deactivate.sh"
