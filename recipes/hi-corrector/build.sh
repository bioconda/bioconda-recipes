#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR/src"
if [[ $target_platform == 'linux-aarch64' ]]; then
  sed -i '1i#include <math.h>' ic.c
  sed -i '1i#include <math.h>' ic_mes.c
  sed -i '1i#include <math.h>' ic_mep.c
  sed -i 's|http:\\/\\/|http://|g' ic_mep.c
  make all CC=$BUILD_PREFIX/bin/aarch64-conda-linux-gnu-cc CCMPI=mpicc LDFLAGS="-lm"
else
  make all CC="$CC" CCMPI="mpicc"
fi
chmod +x "$SRC_DIR/bin/"*
cp -pr "$SRC_DIR/bin" "$PREFIX"
