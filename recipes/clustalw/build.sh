#!/bin/bash

mkdir -p ${PREFIX}
./configure --prefix=$PREFIX
make install
ln -s ${PREFIX}/bin/clustalw2 ${PREFIX}/bin/clustalw
