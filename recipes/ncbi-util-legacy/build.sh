#!/bin/bash

./ncbi/make/makedis.csh 

cp -rL ncbi/include/* "$PREFIX/include/"
cp ncbi/lib/* "$PREFIX/lib/"
cp ncbi/bin/* "$PREFIX/bin/"
