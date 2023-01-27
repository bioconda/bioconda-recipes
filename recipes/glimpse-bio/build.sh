#!/bin/bash

for subdir in chunk split_reference phase ligate

do
    pushd $subdir
    # Build the binaries
    make \
        -j 4 \
        -f "makefile"\
    ;
    # Install the binaries
    install "bin/GLIMPSE2_${subdir}" "${PREFIX}/bin"
    popd
done
