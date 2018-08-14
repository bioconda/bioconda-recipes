#!/bin/bash
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/ditasic/

cp -r * $PREFIX/opt/ditasic/
ln -s $PREFIX/opt/ditasic/ditasic $PREFIX/bin/
ln -s $PREFIX/opt/ditasic/ditasic_mapping.py $PREFIX/bin/
ln -s $PREFIX/opt/ditasic/ditasic_matrix.py $PREFIX/bin/
ln -s $PREFIX/opt/ditasic/core $PREFIX/bin/
