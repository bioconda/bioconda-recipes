#!/bin/bash

cd src
make
mkdir -p $PREFIX/bin
cp ../build/bin/merfin $PREFIX/bin/

