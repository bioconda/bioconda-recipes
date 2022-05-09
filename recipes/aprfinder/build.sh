#!/bin/bash

$CC -std=c99 -g main.c conversion.* switches.*
mv a.out APRfinder
mkdir -p $PREFIX/bin
cp APRfinder $PREFIX/bin
