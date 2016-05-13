#!/bin/bash

if [[ "${PY_VER}" =~ 3 ]]
then
    2to3 -w -n bin/lofreq2_call_pparallel.py
    2to3 -w -n bin/lofreq2_somatic.py
fi

mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
