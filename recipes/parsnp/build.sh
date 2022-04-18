#!/bin/bash

mkdir -p  "$PREFIX/bin"
mkdir -p  "$PREFIX/bin/bin"

cd muscle
./autogen.sh
if [ `uname` == Darwin ]; then
    ./configure --prefix=$PREFIX CXXFLAGS='-fopenmp' --disable-shared 
else
    ./configure --prefix=$PREFIX CXXFLAGS='-fopenmp'
fi
make -j 2
make install

cd ..

# Patch automake update. remove for future release 
#sed '1 s/.*/AC_INIT([parsnp],[1.6.1])/' configure.ac
#sed '2 s/.*/AM_INIT_AUTOMAKE([-Wall])/' configure.ac

./autogen.sh
./configure --with-libmuscle=$PREFIX/include
make LDADD="$LDADD -lMUSCLE-3.7"
make install

rm -R muscle/libMUSCLE
rm -R muscle/autom4te.cache
rm -R muscle/m4

cp parsnp $PREFIX/bin 
cp extend.py $PREFIX/bin
cp logger.py $PREFIX/bin
cp src/parsnp_core $PREFIX/bin/bin
cp template.ini $PREFIX/bin
cp -R bin $PREFIX/bin 
cp -R examples $PREFIX/bin
