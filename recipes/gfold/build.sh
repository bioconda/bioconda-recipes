#!/bin/bash

make

mkdir -p $PREFIX/bin
cp gfold $PREFIX/bin
