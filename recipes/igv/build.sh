#!/bin/bash

mkdir -p $PREFIX/lib
mkdir -p $PREFIX/lib/igv
cp lib/*.jar $PREFIX/lib/igv
sed -i 's/"$prefix"\/lib\/igv.jar/${PREFIX}\/lib\/igv\/igv.jar/g' igv.sh
cp igv.sh $PREFIX/bin/igv
chmod +x $PREFIX/bin/igv
