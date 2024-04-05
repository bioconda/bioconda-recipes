#!/bin/bash
mkdir -p $PREFIX/bin
rm -rf build
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j
cp ./bin/* $PREFIX/bin/
raDir=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $raDir
cp ../vendor/minimap2/minimap2 $raDir/minimap2
cp ./vendor/rala/bin/rala $PREFIX/bin/
cp ./vendor/racon/bin/racon $raDir/racon
sed -i.bak "s|\(__minimap = \)\(.*\)|\1\'${raDir}\/minimap2\'|" $PREFIX/bin/ra
sed -i.bak "s|\(__rala = \).*|\1\'${PREFIX}\/bin\/rala\'|" $PREFIX/bin/ra
sed -i.bak "s|\(__racon = \).*|\1\'${raDir}\/racon\'|" $PREFIX/bin/ra
