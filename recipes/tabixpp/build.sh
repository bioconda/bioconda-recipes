#!/bin/bash
set -x -e

if [ "$(uname)" == "Darwin" ]; then
	sed -i.bak 's/-Wl,-soname/-Wl,-install_name/g' Makefile
	sed -i.bak 's/\.so.$(SONUMBER)/.$(SONUMBER).dylib/g' Makefile
fi

mkdir -p ${PREFIX}/bin

make \
	LIBPATH="-L${PREFIX}/lib" \
	INCLUDES="-I${PREFIX}/include" \
	-v install

#if [ "$(uname)" == "Darwin" ]; then
#	cp libtabixpp.*.dylib ${PREFIX}/lib/
#	ln -s ${PREFIX}/lib/libtabixpp.*.dylib ${PREFIX}/lib/libtabixpp.dylib
#fi

#cp tabix++ ${PREFIX}/bin
#cp *.hpp ${PREFIX}/include
#cp libtabix.a libtabix.so.* ${PREFIX}/lib
#cp libtabixpp.a ${PREFIX}/lib
#cp libtabixpp.so.* ${PREFIX}/lib