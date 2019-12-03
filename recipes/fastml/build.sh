#!/bin/bash

set -e -x -o pipefail
make CC=$GXX CXX=$GXX
mkdir -p ${PREFIX}/bin
cp www/fastml/FastML_Wrapper.pl ${PREFIX}/bin

