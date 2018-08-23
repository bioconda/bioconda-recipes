#!/bin/bash
mkdir -p $PREFIX/bin
cd src
bash make.sh

cp ClonalFrameML $PREFIX/bin
