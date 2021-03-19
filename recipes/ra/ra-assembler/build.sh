#!/bin/bash
mkdir -p $PREFIX/bin
rm -rf build
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j
cp ./bin/* $PREFIX/bin/
cp ../vendor/minimap2/minimap2 $PREFIX/bin/
cp ./vendor/rala/bin/rala $PREFIX/bin/
cp ./vendor/racon/bin/racon $PREFIX/bin/
sed -i.bak "s|\(__minimap = \)\(.*\)|\1\'${PREFIX}\/bin\/minimap2\'|" $PREFIX/bin/ra
sed -i.bak "s|\(__rala = \).*|\1\'${PREFIX}\/bin\/rala\'|" $PREFIX/bin/ra
sed -i.bak "s|\(__racon = \).*|\1\'${PREFIX}\/bin\/racon\'|" $PREFIX/bin/ra
