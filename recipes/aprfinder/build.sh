#!/bin/bash
$CC -std=c99 -g main.c conversion.* switches.*
mv a.out aprfinder
mkdir -p $PREFIX/bin
cp aprfinder $PREFIX/bin
