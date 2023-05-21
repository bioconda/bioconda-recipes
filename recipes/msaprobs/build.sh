#! /bin/bash

mkdir -p $PREFIX/bin
pushd MSAProbs
make all
cp msaprobs $PREFIX/bin/msaprobs
