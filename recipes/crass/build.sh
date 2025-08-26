#!/bin/bash

if [[ $target_platform == 'linux-aarch64' ]];then
	git clone https://github.com/DLTcollab/sse2neon.git
	cp sse2neon/sse2neon.h .
	sed -i 's/emmintrin.h/sse2neon.h/' src/crass/ksw.c

fi

./autogen.sh
./configure --prefix=${PREFIX} --with-xerces=${PREFIX} CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS"
make
make install
