#!/usr/bin/bash

make CC=$CC
mkdir -p $PREFIX/bin

cp ghostz $PREFIX/bin
