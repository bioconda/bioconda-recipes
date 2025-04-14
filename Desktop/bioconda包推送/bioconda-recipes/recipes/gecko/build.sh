#!/bin/bash
mkdir -p $PREFIX/bin
make -C src/ all
cp -r bin/* $PREFIX/bin
