#!/bin/bash

wget http://mattmahoney.net/dc/libzpaq501.zip
wget http://mattmahoney.net/dc/fastqz/fapack.cpp
unzip libzpaq501.zip

g++ -O3 -msse2 -s -lpthread fastqz15.cpp libzpaq.cpp -o fastqz
g++ -O3 -s fapack.cpp -o fapack

cp fastqz $PREFIX/bin/
cp fapack $PREFIX/bin/
chmod +x $PREFIX/bin/fastqz
chmod +x $PREFIX/bin/fapack