#!/bin/bash

make
mkdir -p $PREFIX/bin
cp -R rcorrector run_rcorrector.pl jellyfish/ $PREFIX/bin