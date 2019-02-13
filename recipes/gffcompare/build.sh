#!/bin/bash

mkdir -p $PREFIX/bin
make
install gffcompare $PREFIX/bin/

