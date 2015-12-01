#!/bin/sh

./configure --prefix=$PREFIX --with-readline=gnu CFLAGS="-I$PREFIX/include -I$PREFIX/include/ncurses" CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/ncurses" LDFLAGS="-L$PREFIX/lib" LIBS="-lncurses"
make LDLIBS="-lncurses"
make install

