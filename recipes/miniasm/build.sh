#!/bin/bash

mkdir -p $PREFIX/bin

make 
cp minidot $PREFIX/bin 
cp miniasm $PREFIX/bin

