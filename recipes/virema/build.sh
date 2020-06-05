#!/bin/bash

mkdir -p ${PREFIX}/bin
head -n 2 *.py
cp *.py $PREFIX/bin
chmod +x $PREFIX/bin/*
