#!/bin/bash

mkdir -p $PREFIX/bin/

make
cp seqmap ${PREFIX}/bin/
