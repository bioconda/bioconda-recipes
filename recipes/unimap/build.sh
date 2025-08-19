#!/bin/bash

export CPPFLAGS="${LDFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

install -d "${PREFIX}/bin"

if [[ "$(uname -m)" == "aarch64" ]] || [[ "$(uname -m)" == "arm64" ]]; then
  export EXTRA_ARGS="arm_neon=1 aarch64=1"
  git clone https://github.com/DLTcollab/sse2neon.git
  cp sse2neon/sse2neon.h .
  sed -i.bak '9c #include "sse2neon.h"'  ksw2_ll_sse.c
  sed -i.bak '9c #include "sse2neon.h"'  ksw2_extz2_sse.c
  sed -i.bak '10c #include "sse2neon.h"' ksw2_extd2_sse.c
  sed -i.bak '10c #include "sse2neon.h"' ksw2_exts2_sse.c
else
  export EXTRA_ARGS=""
fi

make CC="${CC}" \
  CFLAGS="${CFLAGS}" \
  CPPFLAGS="${CPPFLAGS} -DHAVE_KALLOC" \
  "${EXTRA_ARGS}" \
  -j"${CPU_COUNT}"

install -v -m 0755 unimap "${PREFIX}/bin"
