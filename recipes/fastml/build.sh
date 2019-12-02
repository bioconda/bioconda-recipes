#!/bin/bash

set -e -x -o pipefail
CC = g++
make CC=$CC
echo "perl ${SRC_DIR}/www/fastml/FastML_Wrapper.pl" > $PREFIX/bin/fastml
chmod +x $PREFIX/bin/fastml

