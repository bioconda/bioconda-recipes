#!/bin/bash

mkdir -p $PREFIX/bin
make CC=$CC
cp quicktree $PREFIX/bin
