#!/bin/bash

make CC="$CC -fcommon"
mkdir -p $PREFIX/bin
cp starcode $PREFIX/bin
