#!/bin/bash

mkdir -p $PREFIX/bin
sed -E -i.bak \
    -e 's/^(CFLAGS|LDFLAGS)=/\1+=/' \
    -e 's/(\s+)gcc \$\(CFLAGS\)/\1$(CC) $(CPPFLAGS) $(CFLAGS)/' \
    Makefile.am
rm Makefile.am.bak
autoreconf --install
./configure \
  --prefix=$PREFIX
  CC="${CC}" \
  CFLAGS="${CFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" \
  LDFLAGS="${LDFLAGS}"
make
make install
