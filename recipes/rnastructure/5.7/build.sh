#!/bin/sh
sed -i.bak "s/version = 5\.6/version = 5.7/" "./src/ParseCommandLine.cpp"
make all
mkdir -p $PREFIX
mv ./* $PREFIX/
ln -s $PREFIX/exe $PREFIX/bin
