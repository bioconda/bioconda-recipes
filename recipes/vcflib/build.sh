#!/bin/bash

export C_INCLUDE_PATH="$PREFIX/include"
export CPLUS_INCLUDE_PATH="$PREFIX/include"

export INCLUDES="-I. -Itabixpp/htslib -Itabixpp -Ismithwaterman -Imultichoose -Ifastahack -Ifilevercmp -Iintervaltree -Ifsom -Igoogletest -IlibVCFH -I$C_INCLUDE_PATH"
export LIBPATH="-L. -Ltabixpp/htslib -L$CPLUS_INCLUDE_PATH"
export LIBS="-lvcflib -lhts -lpthread -lz -lm -llzma -lbz2"
export LDFLAGS="$LIBPATH $LIBS -L${PREFIX}/lib"
export CFLAGS="-Ofast -s -D_FILE_OFFSET_BITS=64"
export CXXFLAGS="-std=c++0x $CFLAGS"

sed -i.bak 's/ld/$(LD)/' smithwaterman/Makefile

#for MOD in multichoose intervaltree tabixpp ; do
#  sed -i.bak 's/g++/$(CXX) $(CXXFLAGS)/g' $MOD/Makefile
#done  

for MOD in filevercmp tabixpp fastahack ; do
  sed -i.bak 's#gcc#$(CC) $(CFLAGS) -L${PREFIX}/lib#g' $MOD/Makefile
done

  
# MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14
if [ "$(uname)" == "Darwin" ]; then
    sed -i.bak 's/LDFLAGS=-Wl,-s/LDFLAGS=/' smithwaterman/Makefile
    export CXXFLAGS="${CFLAGS} -std=c++11 -stdlib=libc++"
    sed -i.bak 's/-std=c++0x/-std=c++11 -stdlib=libc++/g' intervaltree/Makefile
    sed -i.bak 's/-std=c++0x/-std=c++11 -stdlib=libc++/g' Makefile
    sed -i.bak 's/if ( n_data/if ( \*n_data/' src/cdflib.cpp
fi

pushd tabixpp
make CC=$CC CXX=$CXX CXXFLAGS="$CXXFLAGS -Ihtslib" LIBPATH="-L${PREFIX}/lib -L. -Lhtslib" INCLUDES="-Ihtslib"
popd

# -e lets our exported CXX etc override any Makefile settings
make --environment-overrides -j${CPU_COUNT}

mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin

