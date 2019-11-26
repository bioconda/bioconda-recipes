#!/bin/bash

mkdir -p $PREFIX/bin

chmod +x install
./install

shopt -s extglob
for file in $(compgen -G "Pretext!(*cpp)"); do
    chmod +x $file;
    mv $file $PREFIX/bin/
done
