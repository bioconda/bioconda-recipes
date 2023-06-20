#! /bin/sh

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
make
if [ ! -d "$PREFIX/bin" ]; then
        mkdir $PREFIX/bin;
        export PATH=$PREFIX/bin:$PATH;
fi
cp ./derna $PREFIX/bin/
if [ ! -d "$PREFIX/share/derna" ]; then
	mkdir $PREFIX/share/derna;
fi