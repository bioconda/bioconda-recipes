#!/bin/bash
mkdir -p $PREFIX/bin
make
cp age_align $PREFIX/bin
