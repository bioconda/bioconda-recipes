#!/bin/bash

# chanhe makedis interpreter to tcsh
sed -i -e '1s@#!.*@#!/usr/bin/env tcsh@' ./ncbi/make/makedis.csh
./ncbi/make/makedis.csh 

cp -rL ncbi/include/* "$PREFIX/include/"
cp ncbi/lib/* "$PREFIX/lib/"
cp ncbi/bin/* "$PREFIX/bin/"
