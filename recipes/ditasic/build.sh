#!/bin/bash
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/ditasic/

cp -r * $PREFIX/opt/ditasic/
ln -s $PREFIX/opt/ditasic $PREFIX/bin/
ln -s $PREFIX/opt/ditasic/core $PREFIX/bin/
