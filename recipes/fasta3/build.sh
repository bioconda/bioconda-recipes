#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"

mkdir -pv ${PREFIX}/bin ${PREFIX}/share

case $(uname) in
  Darwin) make -j ${CPU_COUNT} -C src -f ../make/Makefile.os_x86_64  all \
            CC="${CC} ${CPPFLAGS} ${CFLAGS}" LDFLAGS="${LDFLAGS}" LIB_M='-lm' ;;
       *) make -j ${CPU_COUNT} -C src -f ../make/Makefile.linux64_sse2 all \
            CC="${CC} ${CPPFLAGS} ${CFLAGS}" LDFLAGS="${LDFLAGS}" LIB_M='-lm' ;;
esac

install -v -m 0755 {bin/*36,bin/map_db,scripts/*.pl,misc/*.pl} "${PREFIX}/bin"
cp -Rf {doc,data,seq} ${PREFIX}/share
