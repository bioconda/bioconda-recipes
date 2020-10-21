#!/bin/bash

make CC=$CC
mkdir -p $PREFIX/bin
cp starcode $PREFIX/bin
