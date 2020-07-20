#!/bin/bash


mkdir -p  "$PREFIX/bin"
mkdir "$PREFIX/bin/bin"

cp parsnp $PREFIX/bin 
cp template.ini $PREFIX/bin
cp bin/parsnp_core "$PREFIX/bin/bin"
