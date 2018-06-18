#!/bin/bash

make all
mkdir -p $PREFIX/bin
cp -f seqtk $PREFIX/bin/
