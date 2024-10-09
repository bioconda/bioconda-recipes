#!/bin/bash

# Run configure script to setup build
./configure

cp -r bin/* ${PREFIX}/bin
cp -r lib/* ${PREFIX}/lib
cp -r param ${PREFIX}
cp -r STarMir ${PREFIX}
source sfoldenv
cp sfoldenv ${PREFIX}
export SFOLDDIR=${PREFIX}

