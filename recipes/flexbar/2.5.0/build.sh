#!/bin/bash

cmake .
make

cp flexbar ${CONDA_PREFIX}/bin
cp *.md ${CONDA_PREFIX}/share/doc/flexbar
