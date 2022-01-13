#!/bin/bash

cd bamcmp-2.1 || true
make
cp build/bamcmp $PREFIX/bin
