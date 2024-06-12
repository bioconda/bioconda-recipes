#!/bin/bash
$CXX -o ProSampler ProSampler_v1.5.cc
mkdir -p $PREFIX/bin
cp ProSampler $PREFIX/bin
