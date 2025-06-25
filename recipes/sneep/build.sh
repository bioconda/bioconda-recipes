#!/bin/bash

cd ${SRC_DIR}/src

mkdir -p ${PREFIX}/bin

if [[ $(uname) == "Linux" ]] ; then
	sed -i.bak 's/CFLAGS=/CFLAGS+=/' Makefile #add bioconda flags and override LD flag because of -static 
	sed -i.bak 's/CFLAGS_=/CFLAGS_+=/' Makefile
	make CC=$CXX LDFLAGS="$LDFLAGS"  
else
        # sed -i.bak -e 's/ -static//' Makefile
	sed -i.bak 's/CFLAGS=/CFLAGS+=/' Makefile
	sed -i.bak 's/LDLAGS_=/LDFLAGS_+=/' Makefile
	sed -i.bak 's/CPPFLAGS_=/CPPFLAGS_+=/' Makefile
	make CC=$CXX LDFLAGS="${LDFLAGS}"
fi

cp -a ${SRC_DIR}/src/. $PREFIX/bin
#chmod +x ${PREFIX}/bin/.


