#!/bin/bash

set -x -e

export LIBRARY_PATH="${PREFIX}/lib"
cd ${LIBRARY_PATH}
wget https://tx.bioreg.kyushu-u.ac.jp/igfinder/igfinder.py

export BINARY_HOME="${PREFIX}/bin"
script=${BINARY_HOME}/igfinder

echo "#!/bin/bash" > $script
echo "python2 ${LIBRARY_PATH}/igfinder.py \$@" >> $script
