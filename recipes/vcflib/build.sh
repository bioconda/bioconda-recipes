#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include

export LDFLAGS="-L$PREFIX/lib -L\$(LIB_DIR) -lvcflib -lhts -lpthread -lz -lm -llzma -lbz2"
export INCLUDES="-I . -Ihtslib -I$PREFIX/include -Itabixpp/htslib -I\$(INC_DIR) -L. -Ltabixpp/htslib"
export LIBPATH="-L. -Lhtslib -L$PREFIX/lib"
export CXXFLAGS="-O3 -D_FILE_OFFSET_BITS=64 -std=c++0x"

#sed -i.bak 's/CFFFLAGS:= -O3/CFFFLAGS=-O3 -D_FILE_OFFSET_BITS=64 -std=c++0x/' smithwaterman/Makefile
#sed -i.bak 's/CFLAGS/CXXFLAGS/g' smithwaterman/Makefile

#sed -i.bak 's/$</$< $(LDFLAGS)/g' smithwaterman/Makefile
sed -i.bak 's/ld/$(LD)/' smithwaterman/Makefile
sed -i.bak 's/gcc/$(CC) $(CFLAGS)/g' filevercmp/Makefile
sed -i.bak 's/g++/$(CXX) $(CXXFLAGS)/g' multichoose/Makefile
sed -i.bak 's/g++/$(CXX) $(CXXFLAGS)/g' intervaltree/Makefile

# MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14
if [ "$(uname)" == "Darwin" ]; then
    sed -i.bak 's/LDFLAGS=-Wl,-s/LDFLAGS=/' smithwaterman/Makefile
    export CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++"
    sed -i.bak 's/-std=c++0x/-std=c++11 -stdlib=libc++/g' intervaltree/Makefile
    sed -i.bak 's/-std=c++0x/-std=c++11 -stdlib=libc++/g' Makefile
    sed -i.bak 's/if ( n_data/if ( \*n_data/' src/cdflib.cpp
    
fi
# tabix missing library https://github.com/ekg/tabixpp/issues/5
# Uses newline trick for OSX from: http://stackoverflow.com/a/24299845/252589
#sed -i.bak 's/SUBDIRS=./SUBDIRS=.\'$'\n''LOBJS=tabix.o/' tabixpp/Makefile
#sed -i.bak 's/-ltabix//' Makefile
#sed -i.bak 's/make/make -e/' Makefile

make -e

mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin

