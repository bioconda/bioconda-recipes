#!/bin/bash

make CC=$CC LINKER=$CC SEARCHDIRS="-I."
mkdir -p $PREFIX/bin
cp mdust $PREFIX/bin
