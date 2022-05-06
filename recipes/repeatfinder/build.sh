#!/bin/bash

$CC -std=c99 -g main.c conversion.* switches.*
mv a.out repeatfinder
mkdir -p $PREFIX/bin
cp repeatfinder $PREFIX/bin

