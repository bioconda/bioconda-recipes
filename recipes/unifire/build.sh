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

# 4. Create fixed-path wrappers for each script
HMMALIGN_PATH=$(which hmmalign)

for script in unifire.sh pirsr.sh fasta-header-validator.sh; do
    base_name=$(basename "$script" .sh)
    wrapper="${INSTALL_DIR}/${base_name}"

    if [[ "$script" == "pirsr.sh" ]]; then
        cat <<EOF > "${wrapper}"
#!/usr/bin/env bash
# Wrapper for pirsr.sh that adds -a ${HMMALIGN_PATH} if -a is not provided
if [[ " \$* " == *" -a "* ]]; then
    exec bash "${INSTALL_DIR}/distribution/bin/${script}" "\$@"
else
    exec bash "${INSTALL_DIR}/distribution/bin/${script}" -a "${HMMALIGN_PATH}" "\$@"
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

# 5. Copy the post-link.sh script into the activate.d directory so that it is printed
# whenever the user activates the conda environment
# see https://docs.conda.io/projects/conda-build/en/latest/resources/activate-scripts.html
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/post-link.sh" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
