#!/bin/bash

sed -i.bak 's/-static//' Makefile

mkdir -p $PREFIX/bin
make
cp kronik $PREFIX/bin
