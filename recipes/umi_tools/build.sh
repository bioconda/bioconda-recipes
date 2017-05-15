#!/bin/bash

$PYTHON setup.py install

# this will create a c file for the extension modules
umi_tools dedup --help %> /dev/null
