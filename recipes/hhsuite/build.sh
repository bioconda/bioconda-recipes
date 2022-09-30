#!/bin/bash
mkdir -p build && cd build
cmake -DCHECK_MPI=0 \
      -DHAVE_MPI=0 \
      -DHAVE_SSE2=1 \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      ..

make -j${CPU_COUNT} ${VERBOSE_CM}
make install -j${CPU_COUNT}
