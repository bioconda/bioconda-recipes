export CFLAGS="-O2 -fopenmp -I$PREFIX/include -I"
cd $SRC_DIR/src
make
cd ../

sed -i.bak "s/jellyfish_dir = quake_dir/jellyfish_dir = $PREFIX\/bin/g" $SRC_DIR/bin/quake.py

mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin/

