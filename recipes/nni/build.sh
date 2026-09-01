#!/bin/bash

export NNI_RELEASE=2.0
NNI_RELEASE=2.0 $PYTHON setup.py build_ts
NNI_RELEASE=2.0 $PYTHON setup.py bdist_wheel