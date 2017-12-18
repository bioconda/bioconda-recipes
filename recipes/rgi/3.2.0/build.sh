#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    echo "Platform: Mac"

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"
fi

# install setup
$PYTHON setup.py install