#!/bin/bash

# Write version in the script
GIT_VERSION=$(git describe --always --tags --long)
n=$(grep '$show_version == true' ./pggb -n | cut -f 1 -d :)
n=$((n-1))
sed -i ${n}'a\if [ $show_version == true ]; then echo "pggb '$GIT_VERSION'"; exit; fi' pggb

mkdir -p $PREFIX/bin
mv pggb $PREFIX/bin
