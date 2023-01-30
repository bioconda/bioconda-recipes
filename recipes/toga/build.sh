#!/bin/bash
export LIBRARY_PATH="$PREFIX/lib"
mkdir -p $PREFIX/bin

./configure.sh
./run_test.sh micro

mv *.py $PREFIX/lib/
