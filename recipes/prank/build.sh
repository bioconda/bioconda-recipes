#!/bin/bash

cd src
make
mkdir -p $PREFIX/bin
cp prank $PREFIX/bin
