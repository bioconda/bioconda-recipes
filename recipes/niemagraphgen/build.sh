#!/bin/bash

mkdir -p ${PREFIX}/bin
make CXX=${CXX}
cp ngg_* ${PREFIX}/bin
