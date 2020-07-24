#!/bin/bash

mkdir -p ${PREFIX}/bin

mv VERSION VERSION.txt  # Breaks C++20
make CC=${CC} CPP=${CXX}


# copy binaries and python scripts
for i in \
    hisat2 \
    hisat2-align-l \
    hisat2-align-s \
    hisat2-build \
    hisat2-build-l \
    hisat2-build-s \
    hisat2-inspect \
    hisat2-inspect-l \
    hisat2-inspect-s \
    *.py \
    hisatgenotype_scripts/*.*;
do
    cp ${i} ${PREFIX}/bin
done

# set permissions
chmod +x ${PREFIX}/bin/*
