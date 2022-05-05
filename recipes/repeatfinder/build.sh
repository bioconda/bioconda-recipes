#!/bin/bash

$CC -std=c99 -g -o repeatfinder main.c conversion.* switches.*

cp repeatfinder $PREFIX/bin

chmod +x $PREFIX/bin/repeatfinder

