#!/usr/bin/env bash
set -euxo pipefail

if [[ "${target_platform}" == osx* ]]; then
    chmod +x decenttree || true
    if [[ -f decenttree ]]; then
        srcbin=decenttree
    else
        srcbin=$(find . -maxdepth 2 -type f -name decenttree | head -n1)
    fi

    install -Dm755 "${srcbin}" "$PREFIX/bin/decenttree"
else
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
    make -j${CPU_COUNT}
    install -Dm755 decenttree $PREFIX/bin/decenttree
fi
