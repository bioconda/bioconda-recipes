#!/bin/bash
sed -i.bak1 's|CFLAGS=\s|CFLAGS= -I${PREFIX}/include |g' Makefile
sed -i.bak2 's|CFLAGS="|CFLAGS="-I${PREFIX}/include |g' Makefile
sed -i.bak3 's|-o $@|-o $@ -L${PREFIX}/lib |g' Makefile
make
install bgzip tabix "$PREFIX/bin"
install libtabix.a libtabix.so.1 "$PREFIX/lib"
