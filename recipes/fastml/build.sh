#!/bin/bash

set -e -x -o pipefail
make CC=$GXX
echo "perl ${SRC_DIR}/www/fastml/FastML_Wrapper.pl" > $PREFIX/bin/fastml
chmod +x $PREFIX/bin/fastml

