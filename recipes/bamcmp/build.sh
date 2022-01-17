#!/bin/bash

cd bamcmp-2.1 || true
make CPP=$CC
cp build/bamcmp $PREFIX/bin
