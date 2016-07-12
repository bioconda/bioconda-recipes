#!/bin/sh
set -x -e

mkdir -p $PREFIX/bin

chmod u+x bin/*
cp bin/* $PREFIX/bin
