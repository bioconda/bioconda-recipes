#!/bin/bash
set -euxo pipefail

cd "${SRC_DIR}"

# Define install target
INSTALL_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
mkdir -p "${INSTALL_DIR}"
mkdir -p "${PREFIX}/bin"

# 1. Build the Java app
mvn clean install -Dmaven.test.skip=true -Dmaven.source.skip=true

# 2. Copy the distribution dir into the image
cd ${SRC_DIR}/distribution
# collect runtime dependencies (JARs)and place them in distribution/target/dependency
mvn dependency:copy-dependencies

# 3. Copy build artifacts
cd "${SRC_DIR}"
rsync -av --exclude='src/test' distribution/ "${INSTALL_DIR}/distribution/"

# 4a. Expose 'unifire', 'pirsr' and 'fasta-header-validator'
for script in unifire.sh pirsr.sh fasta-header-validator.sh; do
    base_name=$(basename "$script" .sh)
    wrapper="${INSTALL_DIR}/${base_name}"

    if [[ "$script" == "pirsr.sh" ]]; then
        cat <<EOF > "${wrapper}"
#!/usr/bin/env bash
# Wrapper for pirsr.sh that adds -a <full-path-to-hmmalign> if -a is not provided

if [[ " \$* " == *" -a "* ]]; then
    exec bash "${INSTALL_DIR}/distribution/bin/${script}" "\$@"
else
    HMMALIGN_PATH=\$(command -v hmmalign)
    if [[ -z "\$HMMALIGN_PATH" ]]; then
        echo "Error: hmmalign not found in PATH but is required by pirsr" >&2
        exit 1
    fi
    exec bash "${INSTALL_DIR}/distribution/bin/${script}" -a "\$HMMALIGN_PATH" "\$@"
fi
EOF
    else
        cat <<EOF > "${wrapper}"
#!/usr/bin/env bash
exec bash "${INSTALL_DIR}/distribution/bin/${script}" "\$@"
EOF
    fi

    chmod +x "${wrapper}"
    ln -s "${wrapper}" "${PREFIX}/bin/${base_name}"
done



# 4b. Expose updateIPRScanWithTaxonomicLineage.py
# as `updateIPRScanWithTaxonomicLineage`
SCRIPT_NAME="updateIPRScanWithTaxonomicLineage"
SCRIPT_SRC="${SRC_DIR}/misc/taxonomy/${SCRIPT_NAME}.py"
SCRIPT_DEST="${INSTALL_DIR}/${SCRIPT_NAME}.py"
WRAPPER="${PREFIX}/bin/${SCRIPT_NAME}"

# Copy the actual Python script into the install dir
cp "${SCRIPT_SRC}" "${SCRIPT_DEST}"

# Create a wrapper to invoke it with python
cat <<EOF > "${WRAPPER}"
#!/usr/bin/env bash
exec python "${SCRIPT_DEST}" "\$@"
EOF

chmod +x "${WRAPPER}"

# 5. Copy the post-link.sh script into the activate.d directory so that it is printed
# whenever the user activates the conda environment
# see https://docs.conda.io/projects/conda-build/en/latest/resources/activate-scripts.html
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/post-link.sh" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
