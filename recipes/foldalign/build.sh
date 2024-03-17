#!/bin/bash

make

mkdir -p $PREFIX/bin

cp -r bin/* $PREFIX/bin
