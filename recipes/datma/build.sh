#!/bin/bash
#chmod +x datma

mkdir -p $PREFIX/bin/
chmod +x *py
cp *py $PREFIX/bin/
chmod +x *sh
cp *sh $PREFIX/bin/

echo "export datmaPATH=$PREFIX/bin/" >> ~/.basrc




