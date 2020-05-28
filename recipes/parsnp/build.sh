#!/bin/bash


mkdir -p  "$PREFIX/bin"

export ORIGIN=\$ORIGIN

cd muscle
./autogen.sh
./configure --prefix=`pwd`
make install
cd ..
./autogen.sh
./configure LDFLAGS='-Wl,-rpath,$$ORIGIN/../muscle/lib'
make LDADD=-lMUSCLE-3.7 
make install

cp template.ini parsnp Parsnp.py bin/ muscle/ $PREFIX/bin/ -r

