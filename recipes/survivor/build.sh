#!/bin/bash

mkdir -p $PREFIX/bin
cd Debug
make
cp SURVIVOR $PREFIX/bin
