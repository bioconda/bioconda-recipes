#!/bin/bash

cp lib/*.jar $PREFIX/lib/igv
sed -i 's/"$prefix"\/lib\/igv.jar/"$prefix"\/..\/lib\/igv\/igv.jar/g' igv.sh
cp igv.sh $PREFIX/bin/igv
chmod +x $PREFIX/bin/igv
