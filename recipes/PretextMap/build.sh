#!/bin/bash

mkdir -p $PREFIX/bin
for file in PretextMap*; do
    chmod +x $file;
    mv $file $PREFIX/bin/
done
