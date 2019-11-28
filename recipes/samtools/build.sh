#!/bin/bash

# varfilter.py in install fails because we don't install Python
sed -i.bak 's#misc/varfilter.py##g' Makefile

# Remove rdynamic which can cause build issues on OSX
# https://sourceforge.net/p/samtools/mailman/message/34699333/
sed -i.bak 's/ -rdynamic//g' Makefile

# Ensure we run successfully using either conda-forge or defaults ncurses
# (unlike other platforms, the latter does not automatically pull in libtinfo)
CURSES_LIB="-ltinfow -lncursesw"

./configure --prefix=$PREFIX --with-htslib=system CURSES_LIB="$CURSES_LIB"
make all
make install
