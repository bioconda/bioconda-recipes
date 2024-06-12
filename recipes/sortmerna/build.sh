#!/bin/bash -xe

mkdir -p ${PREFIX}/bin

if [[ "$(uname)" == "Darwin" ]]; then
    chmod 0755 sortmerna-Darwin/bin/sortmerna
    cp -f sortmerna-Darwin/bin/sortmerna "${PREFIX}/bin"
else
    cd sortmerna
    python setup.py -n all
    chmod 0755 dist/bin/sortmerna
    cp -f dist/bin/sortmerna "${PREFIX}/bin"
fi
