#!/bin/bash
set -euo pipefail

# Patch upstream CMake and replace ccp4-python references to use conda python
# sed -i '/find_package(Python/a set(Python_SITELIB "${SP_DIR}")' CMakeLists.txt
grep -rlIZ --exclude-dir=.git 'ccp4-python' . | xargs -0 sed -i 's/ccp4-python/python/g' || true

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
