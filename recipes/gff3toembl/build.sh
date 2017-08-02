#!/bin/bash

$PYTHON setup.py install


 ln -s ${PREFIX}/include/genometools/ ${PREFIX}/lib/python${CONDA_PY}/site-packages/gt

