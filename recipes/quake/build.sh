gawk -i inplace '/jellyfish_dir = /{ gsub(/quake_dir/, "${PREFIX}/bin");}1' bin/quake.py

export CFLAGS="-O2 -fopenmp -I$PREFIX/include -I"
cd $SRC_DIR/src
make
cd ../

mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin/

