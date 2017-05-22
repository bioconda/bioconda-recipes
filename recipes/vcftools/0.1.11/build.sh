#!/bin/bash
set -euo pipefail
sed -i.bak -e 's/DIRS = cpp perl/DIRS = cpp/' ./Makefile
sed -i.bak -e "s/CFLAGS = /CFLAGS = -I$PREFIX\/include /" ./cpp/Makefile
sed -i.bak -e "s/CPPFLAGS = /CPPFLAGS = -I$PREFIX\/include /" ./cpp/Makefile
sed -i.bak -e "s/LIB = -lz/LIB = -L$PREFIX\/lib -lz /" ./cpp/Makefile
make
make install
