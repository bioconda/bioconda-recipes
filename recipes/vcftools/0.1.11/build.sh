#!/bin/bash
set -euo pipefail
sed -i.bak -e 's/DIRS = cpp perl/DIRS = cpp/' Makefile
sed -i.bak -e "s#CFLAGS = #CFLAGS = -I$PREFIX/include #g" cpp/Makefile
sed -i.bak -e "s#CPPFLAGS = #CPPFLAGS = -I$PREFIX/include #g" cpp/Makefile
sed -i.bak -e "s#LIB = -lz#LIB = -L$PREFIX/lib -lz #g" cpp/Makefile
make
make install
