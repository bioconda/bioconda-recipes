#!/bin/bash

mkdir -p $PREFIX/bin

cd src
make
cp SuSiEx $PREFIX/bin/SuSiEx
