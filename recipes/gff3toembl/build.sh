#!/bin/bash

if [ "${CONDA_PY}" != "27" ]
then
    ln -s ${PREFIX}/lib/python2.7/site-packages/gt ${PREFIX}/lib/python${CONDA_PY:0:1}.${CONDA_PY:1:2}/site-packages/gt
fi



$PYTHON setup.py install




