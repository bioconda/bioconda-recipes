#!/bin/bash

$PYTHON setup.py install


 ln -s ${PREFIX}/include/genometools/ ${PREFIX}/lib/python${TRAVIS_PYTHON_VERSION}/site-packages/gt

