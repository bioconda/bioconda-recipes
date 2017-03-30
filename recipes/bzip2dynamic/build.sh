
#!/bin/sh

# toolchain flags + bzip flags + fpic
export CFLAGS="${CFLAGS} -Wall -Winline -O2 -g -D_FILE_OFFSET_BITS=64 -fPIC"

make -f Makefile-libbz2_so PREFIX=${PREFIX} CFLAGS="$CFLAGS"
cp bzlib.h ${PREFIX}/include
cp libbz2.so.${PKG_VERSION} ${PREFIX}/lib
( cd ${PREFIX}/lib ; ln -s libbz2.so.${PKG_VERSION} libbz2.so.${PKG_VERSION%.*} ; ln -s libbz2.so.${PKG_VERSION} libbz2.so.${PKG_VERSION%.*.*} )
