#!/bin/bash

cmake -Wno-dev -G "Unix Makefiles"  
make

mkdir -p $PREFIX/bin
cp cas-offinder $PREFIX/bin
