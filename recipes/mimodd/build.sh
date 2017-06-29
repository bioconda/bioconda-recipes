#!/bin/bash

export CPATH=${PREFIX}/include

$PYTHON setup.py install
$PYTHON -m MiModD.__first_run__
