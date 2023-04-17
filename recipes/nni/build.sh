#!/bin/bash

export NNI_RELEASE=2.0
$PYTHON setup.py build_ts
$PYTHON setup.py bdist_wheel