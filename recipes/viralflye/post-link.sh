#!/bin/bash

mkdir STAGING

# install viralcomplete data folders
(
    git clone \
        https://github.com/ablab/viralComplete \
        STAGING/viralComplete
    cd STAGING/viralComplete || exit 1
    git checkout -f db9ffa7
    mv blast_db $PREFIX/
    mv data $PREFIX/
)

rm -rf STAGING
