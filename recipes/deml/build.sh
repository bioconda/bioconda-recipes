#!/bin/bash

mkdir -p "$PREFIX/bin"

make
cp src/deML $PREFIX/bin
