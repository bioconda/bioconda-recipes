#!/bin/bash

make

mkdir -p $PREFIX/bin
cp bwa $PREFIX/bin
