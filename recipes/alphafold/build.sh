#!/usr/bin/env bash

pip install . --ignore-installed --no-cache-dir -vvv

cp stereo_chemical_props.txt ${PREFIX}/lib/python3.7/site-packages/lib/python3.7/site-packages/alphafold/common/  

pushd ${PREFIX}/lib/python3.7/site-packages/ && \
    patch -p0 < ./docker/openmm.patch && \
    popd

