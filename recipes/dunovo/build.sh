#!/bin/bash

make
mkdir $PREFIX/include/dunovo
cp *.py *.so $PREFIX/include/dunovo
ln -s ../include/dunovo/correct.py $PREFIX/bin
ln -s ../include/dunovo/align_families.py $PREFIX/bin
ln -s ../include/dunovo/dunovo.py $PREFIX/bin
