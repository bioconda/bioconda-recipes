#!/bin/bash

make

cp swipe $PREFIX/bin 
cp mpiswipe $PREFIX/bin 
chmod +x  $PREFIX/bin/mpiswipe
chmod +x $PREFIX/bin/swipe
