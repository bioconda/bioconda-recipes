#!/bin/bash


mkdir -p  "$PREFIX/bin"

cd muscle
./autogen.sh

if [ `uname` == Darwin ]; then
    ./configure --prefix=$PWD CXXFLAGS='-fopenmp' --disable-shared 
else
    ./configure --prefix=$PWD CXXFLAGS='-fopenmp' 
fi
make install

cd ..
./autogen.sh
export ORIGIN=\$ORIGIN
if [ `uname` == Darwin ]; then
    ./configure LDFLAGS='-Wl,-rpath,$$ORIGIN/../muscle/lib' CXXFLAGS='-fopenmp'
else
    ./configure LDFLAGS='-Wl,-rpath,$$ORIGIN/../muscle/lib' CXXFLAGS='-fopenmp'
fi
make LDADD='-lMUSCLE-3.7' 
make install


cp parsnp $PREFIX/bin 
cp Parsnp.py $PREFIX/bin
cp template.ini $PREFIX/bin
cp -R bin $PREFIX/bin 
cp -R muscle $PREFIX/bin 
cp -R examples $PREFIX/bin

