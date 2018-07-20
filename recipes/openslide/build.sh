#!/usr/bin/env bash

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig:/usr/lib64/pkgconfig:/usr/share/pkgconfig"

autoreconf -i

if  [[ "$OSTYPE" == "darwin"* ]]; then
  ln -s $PREFIX/lib $PREFIX/lib64
  ./configure --prefix=${PREFIX} CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib -Wl,-rpath ${PREFIX}/lib" 
else
  ./configure --prefix=${PREFIX} CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" 
fi

make -j${CPU_COUNT}
make install

