#!/bin/bash

mkdir -p $PREFIX/bin
qmake Bandage.pro
make

cp Bandage $PREFIX/bin/
