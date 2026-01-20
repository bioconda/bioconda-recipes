#!/bin/bash

# copy scripts and its dependencies to $PREFIX/bin folder,
# note that db/ does not contain swissprot nor Pfam data
# to keep the package small

mkdir -p $PREFIX/bin
cp -ar lib \
    bin \
    db \
    *.pl \
    *.sh \
    CHANGES.txt \
    LICENSE.txt \
    $PREFIX/bin
