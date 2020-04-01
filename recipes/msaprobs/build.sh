#! /bin/bash

mkdir -p $PREFIX/bin
(cd $SRC_DIR/MSAProbs && make all)
cp $SRC_DIR/MSAProbs/msaprobs $PREFIX/bin/msaprobs
