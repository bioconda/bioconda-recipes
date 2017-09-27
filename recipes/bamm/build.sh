#!/bin/bash
(rm -rf c/htslib-1.3.1/)
(cd c/ && ./autogen.sh)

$PYTHON setup.py install
