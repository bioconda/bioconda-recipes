#!/bin/bash
cd src
make
cp pathway-pdt $PREFIX/bin
chmod +x $PREFIX/bin/pathway-pdt