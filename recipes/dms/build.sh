#!/bin/bash

mkdir -p ${PREFIX}/bin

make

cat ${PREFIX}/../run_test.sh

cp bin/* ${PREFIX}/bin
cp -r databases ${PREFIX}
cp -r example ${PREFIX}
