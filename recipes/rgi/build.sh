#!/bin/bash

# copy MetaGeneMark key to working directory
cp ./package/rgi/mgm/gm_key ~/.gm_key

# install setup
$PYTHON setup.py install