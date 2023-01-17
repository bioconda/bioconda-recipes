#!/bin/bash
set -ex

export LDFLAGS="${LDFLAGS} -L$PREFIX/lib -lhts -ltabixpp -lpthread -lz -lm -llzma -lbz2"
export INCLUDES="-I . -Ihtslib -I$PREFIX/include -Itabixpp -I\$(INC_DIR) -L."
export LIBPATH="-L. -Lhtslib -L$PREFIX/lib -Ltabixpp"
export CXXFLAGS="${CXXFLAGS} -O3 -D_FILE_OFFSET_BITS=64 -std=c++0x"

sed -i.bak 's/CFFFLAGS:= -O3/CFFFLAGS=-O3 -D_FILE_OFFSET_BITS=64 -std=c++0x/' $PREFIX/contrib/smithwaterman/Makefile
sed -i.bak 's/CFLAGS/CXXFLAGS/g' $PREFIX/contrib/smithwaterman/Makefile

sed -i.bak 's/$</$< $(LDFLAGS)/g' $PREFIX/contrib/smithwaterman/Makefile
sed -i.bak 's/ld/$(LD)/' $PREFIX/contrib/smithwaterman/Makefile
sed -i.bak 's/gcc/$(CC) $(CFLAGS)/g' $PREFIX/contrib/filevercmp/Makefile
sed -i.bak 's/g++/$(CXX) $(CXXFLAGS)/g' $PREFIX/contrib/multichoose/Makefile
sed -i.bak 's/g++/$(CXX) $(CXXFLAGS)/g' $PREFIX/contrib/intervaltree/Makefile

# MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14
if [ "$(uname)" == "Darwin" ]; then
    sed -i.bak 's/LDFLAGS=-Wl,-s/LDFLAGS=/' $PREFIX/contrib/smithwaterman/Makefile
    #export CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++"
    sed -i.bak 's/-std=c++0x/-std=c++11 -stdlib=libc++/g' $PREFIX/contrib/intervaltree/Makefile
    sed -i.bak 's/-std=c++0x/-std=c++11 -stdlib=libc++/g' $PREFIX/Makefile
    sed -i.bak 's/if ( n_data/if ( \*n_data/' $PREFIX/src/cdflib.cpp
    
fi
# tabix missing library https://github.com/ekg/tabixpp/issues/5
# Uses newline trick for OSX from: http://stackoverflow.com/a/24299845/252589
#sed -i.bak 's/SUBDIRS=./SUBDIRS=.\'$'\n''LOBJS=tabix.o/' tabixpp/Makefile
#sed -i.bak 's/-ltabix//' Makefile
#sed -i.bak 's/make/make -e/' Makefile

#make -e \
#    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
#    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"

pkg-config --list-all
mkdir -p $PREFIX/build
cd $PREFIX/build


#cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DTABIXPP_LOCAL:STRING=$PREFIX/lib
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX #-DZIG=OFF
cmake --build . 
cmake --install .
#cp -n ../scripts/* $PREFIX/bin
#cp -n -r ../src/simde $PREFIX/include/
