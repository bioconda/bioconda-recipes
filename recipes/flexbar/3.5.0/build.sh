#!/bin/bash

cmake .
make

cp flexbar $PREFIX/bin
mkdir -p $PREFIX/share/doc/flexbar
cp *.md $PREFIX/share/doc/flexbar
