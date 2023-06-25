#!/bin/bash
set -x -e

# if [ "$(uname)" == "Darwin" ]; then
# 	sed -i.bak 's/-Wl,-soname/-Wl,-install_name/g' Makefile
# 	sed -i.bak 's/\.so.$(SONUMBER)/.$(SONUMBER).dylib/g' Makefile
# fi

# mkdir -p ${PREFIX}/bin
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export CPATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
make CC=gcc #\
	#LIBPATH="-L${PREFIX}/lib" \
	#INCLUDES="-I${PREFIX}/include"

#if [ "$(uname)" == "Darwin" ]; then
#	cp libtabixpp.*.dylib ${PREFIX}/lib/
#	ln -s ${PREFIX}/lib/libtabixpp.*.dylib ${PREFIX}/lib/libtabixpp.dylib
#fi

cp tabix++ ${PREFIX}/bin
cp *.hpp ${PREFIX}/include
cp libtabix.a libtabix.so.* ${PREFIX}/lib
#cp libtabixpp.a ${PREFIX}/lib
#cp libtabixpp.so.* ${PREFIX}/lib
