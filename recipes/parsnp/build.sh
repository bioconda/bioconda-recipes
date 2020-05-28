#!/bin/bash


mkdir -p  "$PREFIX/bin"

export ORIGIN=\$ORIGIN

cd muscle
./autogen.sh
./configure --prefix=`pwd`
make install -ji ${nproc}
cd ..
./autogen.sh
./configure LDFLAGS='-Wl,-rpath,$$ORIGIN/../muscle/lib'
make LDADD=-lMUSCLE-3.7 -j ${nproc}
make install

cp template.ini parsnp Parsnp.py bin/ muscle/ $PREFIX/bin/ -r

