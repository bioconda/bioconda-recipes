#!/bin/bash

mkdir -p  "$PREFIX/bin"
mkdir -p  "$PREFIX/bin/bin"

cd muscle
./autogen.sh
./configure --prefix=$PWD CXXFLAGS='-fopenmp'
make -j 2
make install

cd ..
./autogen.sh
export ORIGIN=\$ORIGIN
./configure LDFLAGS='-Wl,-rpath,$$ORIGIN/../muscle/lib'
make LDADD='-lMUSCLE-3.7'
make install


cp parsnp $PREFIX/bin 
cp src/parsnp_core $PREFIX/bin/bin
cp template.ini $PREFIX/bin
cp -R bin $PREFIX/bin 
cp -R muscle $PREFIX/bin 
cp -R examples $PREFIX/bin
