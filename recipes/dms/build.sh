#!/bin/bash

make

mkdir -p $PREFIX/bin
ls
cp bin/* $PREFIX/bin/
