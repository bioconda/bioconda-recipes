#!/bin/bash

mkdir -pv ${PREFIX}/bin ${PREFIX}/share
case $(uname) in
  Darwin) make -C src -f ../make/Makefile.os_x86_64  all \
            CC="${CC} ${CPPFLAGS} ${CFLAGS}" LDFLAGS="${LDFLAGS}" LIB_M='-lm' ;;
       *) make -C src -f ../make/Makefile.linux64_sse2 all \
            CC="${CC} ${CPPFLAGS} ${CFLAGS}" LDFLAGS="${LDFLAGS}" LIB_M='-lm' ;;
esac
cp {bin/*36,bin/map_db,scripts/*.pl,misc/*.pl} ${PREFIX}/bin
cp -R {doc,data,seq} ${PREFIX}/share
