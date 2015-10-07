#!/bin/bash

mkdir -p $PREFIX/bin

for FILE in igblastn igblastp makeblastdb; do
    cp -f bin/$FILE $PREFIX/bin/
done;
