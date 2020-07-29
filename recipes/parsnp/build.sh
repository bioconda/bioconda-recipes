#!/bin/bash

mkdir -p  "$PREFIX/bin"
mkdir -p  "$PREFIX/bin/bin"

./autogen.sh
export CPLUS_INCLUDE_PATH=$CONDA_PREFIX/include
./configure CXXFLAGS='-I${CONDA_PREFIX}/include -fopenmp -Wl,-rpath,${CONDA_PREFIX}/pkgs/libmuscle-3.7-h470a237_1/lib -L${CONDA_PREFIX}/pkgs/libmuscle-3.7-h470a237_1/lib'
make LDADD='-lMUSCLE-3.7' 
#make install

cp parsnp $PREFIX/bin 
#cp src/parsnp_core $PREFIX/bin/bin
#cp template.ini $PREFIX/bin
#cp -R bin $PREFIX/bin 
#cp -R muscle $PREFIX/bin 
#cp -R examples $PREFIX/bin
