#!/bin/bash

sed -i.bak 's/^CPPFLAGS =$//g' Makefile
sed -i.bak 's/^LDFLAGS  =$//g' Makefile

sed -i.bak 's/^CPPFLAGS =$//g' htslib-$PKG_VERSION/Makefile
sed -i.bak 's/^LDFLAGS  =$//g' htslib-$PKG_VERSION/Makefile

# varfilter.py in install fails because we don't install Python
sed -i.bak 's#misc/varfilter.py##g' Makefile

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

cd htslib*
./configure --prefix=$PREFIX --enable-libcurl CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make
cd ..
./configure --prefix=$PREFIX
make install prefix=$PREFIX LIBS+=-lcurl LIBS+=-lcrypto
