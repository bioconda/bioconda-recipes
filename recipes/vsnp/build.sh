#!/bin/bash

mkdir -p $PREFIX/bin
mv bin/*.py $PREFIX/bin

#prevent clobbering user's reference_options_paths.txt
if [[ ! -f $PREFIX/dependencies/reference_options_paths.txt ]]; then
    mv dependencies $PREFIX # if text file does not exists add dependencies
fi