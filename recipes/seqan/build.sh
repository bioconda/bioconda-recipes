#!/bin/bash

mkdir -p $PREFIX/include
mkdir -p $PREFIX/share
mv include/seqan $PREFIX/include
mv include/share $PREFIX/share
