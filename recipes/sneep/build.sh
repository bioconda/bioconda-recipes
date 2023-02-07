#!/bin/bash

cd ${SRC_DIR}/src

if [[ $(uname) == "Linux" ]] ; then
	sed -i.bak 's/CFLAGS=/CFLAGS+=/' Makefile #add bioconda flags and override LD flag because of -static 
	sed -i.bak 's/CFLAGS_=/CFLAGS_+=/' Makefile
	make CC=$CXX LDFLAGS="$LDFLAGS"  
else
	sed -i.bak 's/CFLAGS=/CFLAGS+=/' Makefile
	sed -i.bak 's/LDLAGS_=/LDFLAGS_+=/' Makefile
	sed -i.bak 's/CPPFLAGS_=/CPPFLAGS_+=/' Makefile
	make CC=$CXX
fi

mkdir -p $PREFIX/bin

cp -a ${SRC_DIR}/src/. $PREFIX/bin

