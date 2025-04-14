#!/bin/bash

mkdir -p $PREFIX/bin
cp gcta-1.94.1 $PREFIX/bin/gcta-1.94.1
ln -s $PREFIX/bin/gcta-1.94.1 $PREFIX/bin/gcta
ln -s $PREFIX/bin/gcta-1.94.1 $PREFIX/bin/gcta64
