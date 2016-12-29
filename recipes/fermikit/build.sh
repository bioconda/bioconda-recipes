#!/bin/bash

mkdir -p $PREFIX/bin

make
mv fermi.kit/* $PREFIX/bin

