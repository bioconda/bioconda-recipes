#!/bin/bash

set -e -x -o pipefail

make
echo "perl ${SRC_DIR}/www/fastml/FastML_Wrapper.pl" > $PREFIX/bin/fastml
chmod +x $PREFIX/bin/fastml

