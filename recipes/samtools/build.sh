#!/bin/bash

# Ensure we run successfully using either conda-forge or defaults ncurses
# (unlike other platforms, the latter does not automatically pull in libtinfo)
CURSES_LIB="-ltinfow -lncursesw"

./configure --prefix=$PREFIX --with-htslib=system CURSES_LIB="$CURSES_LIB"
make all
make install
