#!/bin/bash

./src/Parasail/build

mkdir -p $PREFIX/bin
cp src/ESPRESSO_C.pl $PREFIX/bin/
cp src/ESPRESSO_Q.pl $PREFIX/bin/
cp src/ESPRESSO_Q_Thread.pm $PREFIX/bin/
cp src/ESPRESSO_S.pl $PREFIX/bin/
cp src/ESPRESSO_Version.pm $PREFIX/bin/
cp src/Parasail.pm $PREFIX/bin/
cp src/Parasail.so $PREFIX/bin/

mkdir -p $PREFIX/lib
cp src/libparasail.so $PREFIX/lib/
