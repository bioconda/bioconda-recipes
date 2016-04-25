#!/bin/bash

sed -i.bak 's/^CPPFLAGS =$//g' Makefile
sed -i.bak 's/^LDFLAGS  =$//g' Makefile

sed -i.bak 's~s/@CURSES_LIB@/-lcurses/g~s|@CURSES_LIB@|-lcurses|g~g' Makefile
sed -i.bak "s~-lcurses~$(ncurses${CONDA_NCURSES%.*}-config --libs)~g" Makefile
sed -i.bak 's/^CPPFLAGS =$//g' htslib-$PKG_VERSION/Makefile
sed -i.bak 's/^LDFLAGS  =$//g' htslib-$PKG_VERSION/Makefile

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

make install prefix=$PREFIX
