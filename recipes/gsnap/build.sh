#!/bin/sh

mkdir -p $PREFIX/gmapdb_$PKG_VERSION
env MAX_READLENGTH=500 ./configure --prefix=$PREFIX --with-gmapdb=$PREFIX/gmapdb_$PKG_VERSION
make
make install prefix=$PREFIX 
sed "s/gmapdb_loc=null/gmapdb_loc=gmapdb_$PKG_VERSION/" $RECIPE_DIR/gmap_make_ref.sh > $PREFIX/bin/gmap_make_ref.sh
chmod a+x $PREFIX/bin/gmap_make_ref.sh
