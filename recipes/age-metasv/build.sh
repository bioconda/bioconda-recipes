#!/bin/bash
mkdir -p $PREFIX/bin
make OMP=no
cp age_align $PREFIX/bin
