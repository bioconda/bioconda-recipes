#!/bin/bash

mkdir -p ${PREFIX}/bin

make

cp bin/* ${PREFIX}/bin
cp -r databases ${PREFIX}
