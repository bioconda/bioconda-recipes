#!/bin/bash

mkdir -p $PREFIX/bin/
make fourier
cp fourier $PREFIX/bin/dnp-fourier
