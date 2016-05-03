#!/bin/sh
sed -i.bak "s/version = 5\.6/version = 5.7/" "./src/ParseCommandLine.cpp"
make all
mkdir -p $PREFIX/bin
mv ./exe/* $PREFIX/bin/
