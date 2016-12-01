#!/bin/bash

make 
mkdir -p $PREFIX/bin
cp verifyBamID/bin/verifyBamID $PREFIX/bin

