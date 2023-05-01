#!/bin/bash
set -e
set -o pipefail
set -x

# Tests mp-est on a small test dataset.

TMP=$(mktemp -d)
cd $TMP
wget https://raw.githubusercontent.com/lliu1871/mp-est/master/example/control
wget https://raw.githubusercontent.com/lliu1871/mp-est/master/example/testgenetree

mpest control
