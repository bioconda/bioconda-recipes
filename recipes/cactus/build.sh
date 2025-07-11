#!/bin/bash
${PYTHON} -m pip install .
make
mkdir -p ${PREFIX}/bin
ls -lh
