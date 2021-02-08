#!/bin/bash

echo "00000000000000000000"
mkdir -p ${PREFIX}/bin
echo "11111111111111111111"
export PATH=${PATH}:${PREFIX}/bin
echo "22222222222222222222"
export DynamicMetaStorms=${PREFIX}

echo "33333333333333333333"
echo $PATH
echo "~~~~~~~~~~~~~~~~~~~~"
echo $DynamicMetaStorms
echo "!!!!!!!!!!!!!!!!!!!!"

make

echo "44444444444444444444"

cp bin/* ${PREFIX}/bin
echo "55555555555555555555"
cp -r databases ${PREFIX}
echo "66666666666666666666"
