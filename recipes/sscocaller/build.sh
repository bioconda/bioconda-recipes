#!/bin/sh
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export CFLAGS="-I$PREFIX/include"
export CPATH="${PREFIX}/include"
export CC="${CC}"
export CXX="${CXX}"
export CXXFLAGS="-I$PREFIX/include"


if [ `uname` == Darwin ] ; then
    CXXFLAGS="$CXXFLAGS -stdlib=libc++"
    LDFLAGS="$LDFLAGS -stdlib=libc++"
else ## linux
    CXXFLAGS="$CXXFLAGS"
fi

git clone https://github.com/SurajGupta/r-source
cd r-source
chmod 775 configure
sed -i.bak 's/exit(strncmp(ZLIB_VERSION, "1.2.5", 5) < 0);/exit(ZLIB_VERNUM < 0x1250);/g' configure
./configure --with-readline=no --with-x=no --prefix=$PREFIX --enable-libcurl CFLAGS="-I$PREFIX/include" LDFLAGS="$LDFLAGS" CXXFLAGS="$CXXFLAGS"
cd src/nmath/standalone/
make

cp libRmath* "${PREFIX}/lib"

cd ../../../../
rm -r r-source

nimble --localdeps build -y --verbose -d:release
mkdir -p "${PREFIX}/bin"
cp sscocaller "${PREFIX}/bin/"
