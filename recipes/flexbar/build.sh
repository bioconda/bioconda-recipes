#!/bin/bash

cmake .
make

cp flexbar ${CONDA_PREFIX}/bin
mkdir -p ${CONDA_PREFIX}/share/doc/flexbar
cp *.md ${CONDA_PREFIX}/share/doc/flexbar
