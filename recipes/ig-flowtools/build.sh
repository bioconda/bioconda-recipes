#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share
mv *.R $PREFIX/bin
mv *.py $PREFIX/bin
mv static $PREFIX/share/
mv templates $PREFIX/share/
