#!/bin/bash
 
# When or why do I need to use python setup.py install --single-version-externally-managed --record record.txt?
#
# These options should be added to setup.py if your project uses setuptools. 
# The goal is to prevent setuptools from creating an egg-info directory because they do not interact well with conda.
# https://github.com/conda-forge/staged-recipes/wiki/Frequently-asked-questions

$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
