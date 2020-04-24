#!/bin/bash

make CC=$CC
mkdir -p $PREFIX/bin
cp sumaclust $PREFIX/bin
chmod +x $PREFIX/bin/sumaclust
