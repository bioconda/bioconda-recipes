#!/bin/sh

cd source
make

mkdir -p $PREFIX/bin

cp readal $PREFIX/bin
cp statal $PREFIX/bin
cp trimal $PREFIX/bin

