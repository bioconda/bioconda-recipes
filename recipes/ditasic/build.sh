#!/bin/bash
mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/opt/ditasic"

cd src
cp -r * "${PREFIX}/opt/ditasic/"
ln -s \
    "${PREFIX}/opt/ditasic/ditasic" \
    "${PREFIX}/opt/ditasic/ditasic_mapping.py" \
    "${PREFIX}/opt/ditasic/ditasic_matrix.py" \
    "${PREFIX}/opt/ditasic/core" \
    "${PREFIX}/bin/"
