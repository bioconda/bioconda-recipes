#!/bin/bash

git submodule update --init --recursive
make
mkdir -p $PREFIX/bin
mv conifer $PREFIX/bin
