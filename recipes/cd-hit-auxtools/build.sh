#!/bin/sh
cd cd-hit-auxtools

mkdir -p $PREFIX/bin
make

mv cd-hit-dup $PREFIX/bin
mv cd-hit-lap $PREFIX/bin
mv read-linker $PREFIX/bin
