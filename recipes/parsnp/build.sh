#!/bin/bash


mkdir -p  "$PREFIX/bin"



./autogen.sh
export CPLUS_INCLUDE_PATH=$PREFIX/include
./configure CXXFLAGS='-I${PREFIX}/include -fopenmp' --with-libmuscle=${PREFIX}/include/libMUSCLE-3.7
make LDADD='-lMUSCLE-3.7' 
make install


cp parsnp $PREFIX/bin 
cp Parsnp.py $PREFIX/bin
cp template.ini $PREFIX/bin
cp -R bin $PREFIX/bin 
cp -R examples $PREFIX/bin

