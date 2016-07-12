#!/bin/sh
set -x -e

mkdir -p $PREFIX/bin

chmod 777 bin/*
cp bin/* $PREFIX/bin
