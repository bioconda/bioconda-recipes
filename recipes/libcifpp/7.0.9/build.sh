#!/bin/bash

set -exo pipefail

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-int-conversion -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS} -O3"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"

if [[ $(uname) == "Darwin" ]]; then
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
    export CONFIG_ARGS=""
fi

# Refer to https://github.com/conda-forge/dssp-feedstock/pull/14#issuecomment-2974049079 about `-DCIFPP_DATA_DIR=''`
cmake -S . -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=OFF \
    -DCIFPP_DOWNLOAD_CCD=ON \
    -DCIFPP_INSTALL_UPDATE_SCRIPT=OFF \
    -DCIFPP_DATA_DIR='' \
    -DCIFPP_SHARE_DIR="${PREFIX}/share/libcifpp" \
    ${CONFIG_ARGS}

cmake --build build/ --target install -j "${CPU_COUNT}"
install -m 644 "${SRC_DIR}/rsrc/components.cif" "${PREFIX}/share/libcifpp/components.cif"

# activaton and deactivation scripts
mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
install -m 755 "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/libcifpp_activate.sh"
install -m 755 "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/libcifpp_deactivate.sh"
install -m 755 "${RECIPE_DIR}/activate.fish" "${PREFIX}/etc/conda/activate.d/libcifpp_activate.fish"
install -m 755 "${RECIPE_DIR}/deactivate.fish" "${PREFIX}/etc/conda/deactivate.d/libcifpp_deactivate.fish"
