#!/bin/bash

mkdir -p $PREFIX/bin
cp scripts/* bin/
chmod 755 bin/*
cp -r * $PREFIX/
