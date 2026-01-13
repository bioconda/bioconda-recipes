#!/bin/bash

python -m pip install "git+https://github.com/AngieHinrichs/viral_usher.git" --no-deps --ignore-installed --no-cache-dir

# Copy metaWEPP files to $PREFIX/metaWEPP
#mkdir -p "${PREFIX}/bin"
mkdir -p ${PREFIX}/metaWEPP
cp -rf "${SRC_DIR}"/* "${PREFIX}/metaWEPP"

# Creates a function 'snakemake' that injects the -s argument
ACTIVATE_DIR="${PREFIX}/etc/conda/activate.d"
DEACTIVATE_DIR="${PREFIX}/etc/conda/deactivate.d"
mkdir -p "${ACTIVATE_DIR}" "${DEACTIVATE_DIR}"

cat <<'EOF' > "${ACTIVATE_DIR}/metawepp_activate.sh"
#!/bin/bash

# Store the original snakemake command location if needed, or just use 'command'
snakemake() {
    # Check if the user manually provided -s or --snakefile
    if [[ "$*" == *"-s "* ]] || [[ "$*" == *"--snakefile "* ]]; then
        command snakemake "$@"
    else
        # Inject the metaWEPP Snakefile path
        command snakemake -s "$CONDA_PREFIX/metaWEPP/Snakefile" "$@"
    fi
}
export -f snakemake 2>/dev/null || true
EOF

# Removes the function when the user exits the environment
cat <<'EOF' > "${DEACTIVATE_DIR}/metawepp_deactivate.sh"
#!/bin/bash
unset -f snakemake
EOF

chmod +x "${ACTIVATE_DIR}/metawepp_activate.sh"
chmod +x "${DEACTIVATE_DIR}/metawepp_deactivate.sh"
