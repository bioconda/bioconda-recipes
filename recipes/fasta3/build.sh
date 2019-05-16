#!/bin/bash

mkdir -pv ${PREFIX}/bin ${PREFIX}/share
case $(uname) in
  Darwin) make -C src -f ../make/Makefile.os_x86_64  all LIB_M='-lm' ;;
       *) make -C src -f ../make/Makefile.linux_sse2 all LIB_M='-lm' ;;
esac
cp {bin/*36,bin/map_db,scripts/*.pl,misc/*.pl} ${PREFIX}/bin
cp -R {doc,data,seq} ${PREFIX}/share
