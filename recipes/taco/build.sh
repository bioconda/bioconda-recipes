#/bin/bash

./build.sh
mkdir -p $PREFIX/bin
cp taco_run $PREFIX/bin
cp taco_refcomp $PREFIX/bin
