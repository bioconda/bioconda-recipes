#!/bin/bash

cd $SRC_DIR/ext
wget -O seqtk.tar.gz https://github.com/lh3/seqtk/archive/d3b53c9.tar.gz
tar -xvf seqtk.tar.gz -C seqtk --strip-components 1
cd ..

mkdir -p $PREFIX/bin
sed -E -i.bak \
    -e 's/^(CFLAGS|LDFLAGS)=/\1+=/' \
    -e 's/(\s+)gcc \$\(CFLAGS\)/\1$(CC) $(CPPFLAGS) $(CFLAGS)/' \
    Makefile.am
rm Makefile.am.bak
autoreconf --install
./configure
make \
    CC="${CC}" \
    CFLAGS="${CFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
mv orfm  $PREFIX/bin
