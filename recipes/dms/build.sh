#!/bin/bash

mkdir -p ${PREFIX}/bin

export DynamicMetaStorms=${PREFIX}

make

cp bin/* ${PREFIX}/bin
cp -r databases ${PREFIX}
