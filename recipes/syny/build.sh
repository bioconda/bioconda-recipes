#!/bin/sh

BIN=${PREFIX}/bin
mkdir -p $BIN
cp -R * $BIN

## Creating symlinks in ${PREFIX}/bin for scripts located in SYNY subdirectories
for subdir in {'Alignments','Clusters','Examples','Plots','Utils'}; do
    for script in $subdir/*.{py,pl,sh}; do
        if [[ "$script" =~ '*' ]]; then 
            continue
        else
            echo "${PREFIX}/bin/$script"
            ln -s "${PREFIX}/bin/$script" ${PREFIX}/bin/
        fi
    done
done