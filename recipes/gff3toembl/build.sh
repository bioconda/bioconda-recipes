#!/bin/bash

 ln -s ${PREFIX}/include/genometools/ ${PREFIX}/lib/python${CONDA_PY:0:1}.${CONDA_PY:1:2}/site-packages/gt


$PYTHON setup.py install


