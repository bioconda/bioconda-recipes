#!/bin/bash

export CC=${CC:-gcc}
export CXX=${CXX:-g++}

#./install.sh
cd RabbitSketch &&
mkdir -p build && cd build &&
cmake -DCXXAPI=ON -DCMAKE_INSTALL_PREFIX=. .. &&
make -j ${CPU_COUNT} && make install &&
cd ../../ &&

#make rabbitFX library
cd RabbitFX && 
mkdir -p build && cd build &&
cmake -DCMAKE_INSTALL_PREFIX=. .. &&
make -j ${CPU_COUNT} && make install && 
cd ../../ &&

#compile the clust-greedy
mkdir -p build && cd build &&
cmake -DUSE_RABBITFX=ON -DUSE_GREEDY=ON .. && 
make -j ${CPU_COUNT} && make install &&
cd ../ &&

#compile the clust-mst
cd build &&
cmake -DUSE_RABBITFX=ON -DUSE_GREEDY=OFF .. &&
make -j ${CPU_COUNT} && make install &&
cd ../ 

mkdir -p $PREFIX/bin
cp clust-mst $PREFIX/bin/
cp clust-greedy $PREFIX/bin/

#export LIBRARY_DIRS="$LIBRARY_DIRS $PREFIX/lib"

#make BIOCONDA=1
#make install

