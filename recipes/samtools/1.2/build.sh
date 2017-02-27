#!/bin/bash

sed -i.bak 's/^CPPFLAGS =$//g' Makefile
sed -i.bak 's/^LDFLAGS  =$//g' Makefile

sed -i.bak 's/^CPPFLAGS =$//g' htslib-*/Makefile
sed -i.bak 's/^LDFLAGS  =$//g' htslib-*/Makefile

# varfilter.py in install fails because we don't install Python
sed -i.bak 's#misc/varfilter.py##g' Makefile

# Remove rdynamic which can cause build issues on OSX
# https://sourceforge.net/p/samtools/mailman/message/34699333/
sed -i.bak 's/ -rdynamic//g' Makefile
sed -i.bak 's/ -rdynamic//g' htslib-*/configure

export CXX_INCLUDE_PATH=${PREFIX}/include:${PREFIX}/include/ncurses

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

cd htslib*
./configure --prefix=$PREFIX --enable-libcurl CFLAGS="-I$PREFIX/include -I$NCURSES_INCLUDE_PATH/ncurses" LDFLAGS="-L$PREFIX/lib"
make
cd ..

sed -i.bak -e 's/-lcurses/-lncurses -ltinfo/' Makefile
sed -i.bak -e "s|CFLAGS=\s*-g\s*-Wall\s*-O2\s*|CFLAGS= -g -Wall -O2 -I$NCURSES_INCLUDE_PATH/ncurses/ I$PREFIX/include/ncurses -I/ncurses/ -I$NCURSES_INCLUDE_PATH -L$NCURSES_LIB_PATH|g" Makefile
make install prefix=$PREFIX
