#!/bin/bash

./configure --prefix=$PREFIX --with-boost=$PREFIX/include --with-mpi=$PREFIX/include --enable-maxk=96
make AM_CXXFLAGS=-Wall
make install

# install the abyss-pe wrapper
mv $PREFIX/bin/abyss-pe $PREFIX/bin/abyss-pe-actual
cp $RECIPE_DIR/abyss-pe-wrapper $PREFIX/bin/abyss-pe
chmod +x $PREFIX/bin/abyss-pe
