#!/bin/bash

$PYTHON setup.py install


 mv ${PREFIX}/include/genometools/genometools.h ${PREFIX}/include/genometools/gt.h 


 ln -s ${PREFIX}/include/genometools/ ${PREFIX}/lib/python3.5/site-packages/gt

