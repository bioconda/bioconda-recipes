#!/bin/bash

mkdir -p ${PREFIX}
./configure --prefix=$PREFIX
make install
