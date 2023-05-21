#!/bin/bash

mv nucamino-* nucamino_binary
chmod a+x nucamino_binary
mkdir -p $PREFIX/bin
cp nucamino_binary $PREFIX/bin/nucamino
