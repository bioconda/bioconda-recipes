#!/bin/bash

# Remove configure.ac C(XX)?FLAGS override
sed -i.bak 's/ *CX\?X\?FLAGS/#\0/p' configure.ac
# Remove MACOS_DEPLOYMENT_TARGET override
sed -i.bak 's/MACOSX_DEPLOYMENT_TARGET=/#\0/' configure.ac
sed -i.bak 's/export MACOSX_DEPLOYMENT_TARGET=/#\0/' src/Makefile.am

./autogen.sh
./configure --prefix=$PREFIX
make
make install
