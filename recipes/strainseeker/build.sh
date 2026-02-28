#!/bin/bash

mkdir -p ${PREFIX}/bin

chmod 0755 scripts/*
chmod 0755 bin/*
cp scripts/* ${PREFIX}/bin/
cp bin/* $PREFIX/bin/
