#!/bin/bash

ARCH_BUILD=""
case $(uname -m) in
    x86_64) ARCH_BUILD="-DHAVE_SSE4_1=1" ;;
    arm64|aarch64) ARCH_BUILD="-DHAVE_ARM8=1" ;;
esac

if [ -z "${ARCH_BUILD}" ]; then
    echo "Invalid architecture"
    exit 1
fi

mkdir -p build && cd build
cmake -DCHECK_MPI=0 \
      -DHAVE_MPI=0 \
      ${ARCH_BUILD} \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      ..

make -j${CPU_COUNT} ${VERBOSE_CM}
make install -j${CPU_COUNT}

# Move the `reformat.pl` script to ${PREFIX}/bin to ensure it's available in the PATH
mv ${SRC_DIR}/scripts/reformat.pl ${PREFIX}/bin
