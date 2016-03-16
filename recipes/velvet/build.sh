#!/bin/bash

make 
mkdir -p $PREFIX/bin
cp velvetg velveth $PREFIX/bin
