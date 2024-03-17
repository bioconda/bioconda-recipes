#! /bin/bash

export CPATH=${PREFIX}/include
make

cp marvin $PREFIX/bin/
cp marvin_prep $PREFIX/bin/
chmod +x $PREFIX/bin/marvin
chmod +x $PREFIX/bin/marvin_prep