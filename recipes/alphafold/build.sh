#!/usr/bin/env bash

wget -q -P ${PREFIX}/lib/python3.7/site-packages/lib/python3.7/site-packages/alphafold/common/ \
  https://git.scicore.unibas.ch/schwede/openstructure/-/raw/7102c63615b64735c4941278d92b554ec94415f8/modules/mol/alg/src/stereo_chemical_props.txt

pushd ${PREFIX}/lib/python3.7/site-packages/ && \
    patch -p0 < ./docker/openmm.patch && \
    popd

