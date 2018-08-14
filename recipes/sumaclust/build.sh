#!/bin/bash

make
mkdir -p $PREFIX/bin
cp sumaclust $PREFIX/bin
chmod +x $PREFIX/bin/sumaclust
