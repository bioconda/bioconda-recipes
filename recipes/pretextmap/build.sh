#!/bin/bash

mkdir -p $PREFIX/bin
for file in Pretext*; do
    chmod +x $file;
    mv $file $PREFIX/bin/
done
