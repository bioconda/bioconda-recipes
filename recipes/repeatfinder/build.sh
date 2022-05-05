#!/bin/bash

$CC -std=c99 -g -o repeatfinder main.c conversion.* switches.*
mkdir -p $PREFIX/bin
cp repeatfinder $PREFIX/bin

