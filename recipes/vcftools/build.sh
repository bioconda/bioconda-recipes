#!/bin/bash
set -euo pipefail
./autogen.sh
./configure --prefix=$PREFIX
#sed -i.bak -e 's/SUBDIRS = cpp perl/SUBDIRS = cpp/' ./src/Makefile
make
make install
