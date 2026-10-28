#!/bin/bash

sed -i.bak 's/^CPPFLAGS =$//g' Makefile
sed -i.bak 's/^LDFLAGS  =$//g' Makefile

sed -i.bak 's/^CPPFLAGS =$//g' htslib-$PKG_VERSION/Makefile
sed -i.bak 's/^LDFLAGS  =$//g' htslib-$PKG_VERSION/Makefile

# varfilter.py in install fails because we don't install Python
sed -i.bak 's#misc/varfilter.py##g' Makefile

# Remove rdynamic which can cause build issues on OSX
# https://sourceforge.net/p/samtools/mailman/message/34699333/
sed -i.bak 's/ -rdynamic//g' Makefile
sed -i.bak 's/ -rdynamic//g' htslib-$PKG_VERSION/configure

export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include -Wno-deprecated-declarations"

cd htslib*
./configure --prefix="$PREFIX" --enable-libcurl CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
make
cd ..
# Problem with ncurses from default channel we now get in bioconda so skip tview
# https://github.com/samtools/samtools/issues/577
./configure --prefix="$PREFIX" --enable-libcurl --without-curses
make install prefix="$PREFIX" LIBS+=-lcrypto LIBS+=-lcurl
