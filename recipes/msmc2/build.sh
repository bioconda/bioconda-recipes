#!/bin/bash
mkdir -p $PREFIX/bin
make CC=$CC
cp build/release/* $PREFIX/bin

