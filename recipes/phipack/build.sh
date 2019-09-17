#!/bin/sh

cd src/

make
cp ../Phi $PREFIX/bin
cp ../ppma_2_bmp $PREFIX/bin
cp ../Profile $PREFIX/bin

chmod +x $PREFIX/bin/Phi
chmod +x $PREFIX/bin/ppma_2_bmp
chmod +x $PREFIX/bin/Profile
