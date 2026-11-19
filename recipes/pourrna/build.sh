#!/bin/sh
set -eux

case "${target_platform}" in
    osx-*)
        # ViennaRNA's RNAlib2.pc carries Linux-only link flags that Apple ld64 rejects
        sed -i.bak \
            -e 's/-Wl,-fno-lto//g' \
            -e 's/-fno-lto//g' \
            -e 's/-lstdc++//g' \
            "${PREFIX}/lib/pkgconfig/RNAlib2.pc"
        rm -f "${PREFIX}/lib/pkgconfig/RNAlib2.pc.bak"
        ;;
esac

./configure \
    --prefix="${PREFIX}" \
    --with-RNA="${PREFIX}" \
    || { sed -n '/whether ViennaRNA/,/failed program was/p' config.log; exit 1; }

make -j"${CPU_COUNT}"
make install
make check
