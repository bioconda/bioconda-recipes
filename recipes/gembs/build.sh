#!/bin/bash

#instead of installing software from submodules, let them be dependencies

$PYTHON setup.py install --minimal --single-version-externally-managed --record=record.txt

