#!/bin/bash

mkdir -p $PREFIX/bin
make
mv agg $PREFIX/bin
