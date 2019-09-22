#!/bin/bash

mkdir -p $PREFIX/include
mkdir -p $PREFIX/share/cmake/Modules
mkdir -p $PREFIX/share/doc
mkdir -p $PREFIX/share/pkgconfig
mv include/seqan $PREFIX/include
mv share/cmake/Modules/* $PREFIX/share/cmake/Modules
mv share/doc/seqan $PREFIX/share/doc
mv share/pkgconfig/* $PREFIX/share/pkgconfig
