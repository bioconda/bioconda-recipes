#!/bin/bash
$CXX -o ProSampler ProSampler.cc
mkdir -p $PREFIX/bin
cp ProSampler $PREFIX/bin
