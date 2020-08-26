#!/bin/sh

set -x -e -o pipefail

make \
  CC="${CC}" \
  CFLAGS="${CPPFLAGS} ${CFLAGS} -g -Wall -O3 ${LDFLAGS}" \
  LIBCURSES=-lncurses

mkdir -p "${PREFIX}/bin"

cp dwgsim dwgsim_eval "${PREFIX}/bin/"
