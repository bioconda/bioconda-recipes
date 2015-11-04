#!/bin/bash

BASE=$PREFIX/../..

LIBRARY_PATH=$BASE/lib CPATH=$BASE/include make

mkdir -p $PREFIX/bin
cp gfold $PREFIX/bin
