#!/bin/bash
# Workaround for circular dependency
$PYTHON -m pip install SPARQLWrapper
$PYTHON setup.py install
