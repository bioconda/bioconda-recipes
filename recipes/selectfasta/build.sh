#!/bin/bash
echo "selectFasta compilation"
make CPP=${CXX}
mkdir -p $PREFIX/bin
cp selectFasta $PREFIX/bin
chmod +x $PREFIX/bin/selectFasta
echo "Installation successful"
