#!/bin/bash

set -e -x -o pipefail
make CC=$GXX CXX=$GXX
cp ${SRC_DIR}/www/fastml/FastML_Wrapper.pl $PREFIX/bin
#echo "perl $PREFIX/bin/FastML_Wrapper.pl" > $PREFIX/bin/fastml
#chmod +x $PREFIX/bin/fastml

