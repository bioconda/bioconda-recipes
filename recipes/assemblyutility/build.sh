#!/bin/bash

mkdir -p $PREFIX/bin; 
g++ -O3 -o AssemblyStatistics AssemblyStatistics.cpp; 
mv AssemblyStatistics $PREFIX/bin

g++ -O3 -o SelectLongestReads SelectLongestReads.cpp;
mv SelectLongestReads $PREFIX/bin
