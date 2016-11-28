#!/bin/bash
cd remuRNA
make

#Copy binery file since there is no INSTALL part in the makefile
cp remuRNA $PREFIX/bin
#Copy data folder. not sure if putting this folder in the main conda folder is "wise", but this tool won't work otherwise
cp data/ $PREFIX -r
