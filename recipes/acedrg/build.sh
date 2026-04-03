#!/bin/bash
set -euo pipefail

if [[ "${target_platform}" == "linux-aarch64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
elif [[ "${target_platform}" == "osx-arm64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
else
  export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
fi

# Patch upstream CMake and replace ccp4-python references to use conda python
grep -rlIZ --exclude-dir=.git 'ccp4-python' . | xargs -0 sed -i 's|ccp4-python|python|g'

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_CXX_STANDARD=17 \
    -DPython_EXECUTABLE="${PYTHON}" \
    -DPYTHON_VERSION=3 \
    -DPython_SITELIB="${SP_DIR}"
cmake --build build --parallel ${CPU_COUNT}
cmake --install build --parallel ${CPU_COUNT}

# Create a symlink for libmol if the upstream build installs it under libexec
if [ -e "${PREFIX}/libexec/libmol" ] && [ ! -e "${PREFIX}/bin/libmol" ]; then
    ln -sf "${PREFIX}/libexec/libmol" "${PREFIX}/bin/libmol"
fi

mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
install -m 755 "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
install -m 755 "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"
install -m 755 "${RECIPE_DIR}/activate.fish" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.fish"
install -m 755 "${RECIPE_DIR}/deactivate.fish" "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.fish"
install -m 755 "${RECIPE_DIR}/activate.ps1" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.ps1"
install -m 755 "${RECIPE_DIR}/deactivate.ps1" "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.ps1"
install -m 755 "${RECIPE_DIR}/activate.xsh" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.xsh"
install -m 755 "${RECIPE_DIR}/deactivate.xsh" "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.xsh"
