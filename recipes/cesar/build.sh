#!/bin/bash

mkdir -p $PREFIX/bin
ln -s ${CC} $BUILD_PREFIX/bin/gcc
ln -s ${CXX} $BUILD_PREFIX/bin/g++
make


cp cesar $PREFIX/bin
