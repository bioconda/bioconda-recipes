#!/bin/bash

cd src
LDFLAGS=$LDFLAGS" -lomp" make
mkdir -p $PREFIX/bin
cp ../build/bin/merfin $PREFIX/bin/

