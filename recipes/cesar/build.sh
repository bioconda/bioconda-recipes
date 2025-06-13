#!/bin/bash

mkdir -p $PREFIX/bin
make CC=${CC}
cp cesar $PREFIX/bin
