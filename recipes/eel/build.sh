#!/bin/bash

#  Fri Mar 22 15:35:47 2019
#  kpalin@minea-ltdk-17.it.helsinki.fi

# For debugging
#set -o verbose 

# Die on unset variables
set -o nounset
# Die on errors
set -o errexit
# Die if any part of a pipe fails
set -o pipefail




export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

$PYTHON setup.py install  
