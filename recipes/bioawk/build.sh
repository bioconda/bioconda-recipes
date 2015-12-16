#!/bin/bash

make

mkdir -p $PREFIX/bin
cp bioawk $PREFIX/bin
