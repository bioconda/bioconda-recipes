#!/bin/bash
set -x -e -o pipefail
if [[ ${target_platform} == "linux-aarch64" ]]; then
  sed -i.bak '4c\DFLAGS=         -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE -D_USE_KNETFILE -DPACKAGE_VERSION=\\\\\\\"${PACKAGE_VERSION}\\\\\\\" -Dunreachable=dwgsim_unreachable' Makefile
  sed -i.bak 's/unreachable/dwgsim_unreachable/g' src/dwgsim.c
  sed -i.bak '8a CFLAGS += $(DFLAGS)' samtools/Makefile
fi
make CC="${CC}" CFLAGS="${CPPFLAGS} ${CFLAGS} -g -Wall -O3 ${LDFLAGS}" LIBCURSES="-lncurses" -j"${CPU_COUNT}"

mkdir -p "${PREFIX}/bin"

install -v -m 755 dwgsim dwgsim_eval "${PREFIX}/bin"
