#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
curl-config --ca
$PYTHON setup.py install
