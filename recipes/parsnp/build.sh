#!/bin/bash


mkdir -p  "$PREFIX/bin"
mkdir "$PREFIX/bin/bin"

cp parsnp examples template.ini $PREFIX/bin -R
cp bin/parsnp_core "$PREFIX/bin/bin"
