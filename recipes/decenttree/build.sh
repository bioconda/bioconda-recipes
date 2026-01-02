#!/usr/bin/env bash
set -euxo pipefail

if [[ "${target_platform}" == osx* ]]; then
    archive_dir="decenttree-${PKG_VERSION}-MacOSX"
    srcbin="${archive_dir}/bin/decenttree"

    if [[ ! -x "${srcbin}" ]]; then
        echo "ERROR: expected macOS binary not found at ${srcbin}" >&2
        find "${archive_dir}" -type f -maxdepth 3 -print >&2
        exit 1
    fi

    install -Dm755 "${srcbin}" "$PREFIX/bin/decenttree"
else
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
    make -j${CPU_COUNT}
    install -Dm755 decenttree $PREFIX/bin/decenttree
fi
