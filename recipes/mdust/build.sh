#!/bin/bash

make CC=$CC LINKER=$CC
mkdir -p $PREFIX/bin
cp mdust $PREFIX/bin
