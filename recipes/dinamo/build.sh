#!/bin/bash
sed -i 's/-I include/-I include -I ${PREFIX}\/include/' Makefile 
make 

mkdir -p $PREFIX/bin/
cp bin/dinamo $PREFIX/bin/
