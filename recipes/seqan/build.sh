#!/bin/bash

mkdir -p $PREFIX/include
mkdir -p $PREFIX/share/cmake
mkdir -p $PREFIX/share/doc
mkdir -p $PREFIX/share/pkgconfig
mv include/seqan $PREFIX/include
mv share/cmake/seqan $PREFIX/share/cmake
mv share/doc/seqan $PREFIX/share/doc
mv share/pkgconfig/* $PREFIX/share/pkgconfig
