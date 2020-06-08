#!/bin/bash


mkdir -p  "$PREFIX/bin"

./autogen.sh
>&2 ls ${CONDA_PREFIX}/*/*
./configure CXXFLAGS='-fopenmp' --with-libmuscle=${CONDA_PREFIX}/include/libMUSCLE-3.7
make LDADD='-lMUSCLE-3.7' 
make install


cp parsnp $PREFIX/bin 
cp Parsnp.py $PREFIX/bin
cp template.ini $PREFIX/bin
cp -R bin $PREFIX/bin 
cp -R muscle $PREFIX/bin 
cp -R examples $PREFIX/bin

