#!/bin/bash


mkdir -p  "$PREFIX/bin"

cd muscle
./autogen.sh
./configure --prefix=$PWD CXXFLAGS='-fopenmp' 
make install

cd ..
./autogen.sh
export ORIGIN=\$ORIGIN
./configure LDFLAGS='-Wl,-rpath,$$ORIGIN/../muscle/lib' CXXFLAGS='-fopenmp'
make LDADD='-lMUSCLE-3.7' 
make install


cp parsnp $PREFIX/bin 
cp Parsnp.py $PREFIX/bin
cp template.ini $PREFIX/bin
cp -R bin $PREFIX/bin 
cp -R muscle $PREFIX/bin 
cp -R examples $PREFIX/bin

