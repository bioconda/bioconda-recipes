#!/bin/bash

make fourier 
cp fourier $PREFIX/bin
rm -f -r include
