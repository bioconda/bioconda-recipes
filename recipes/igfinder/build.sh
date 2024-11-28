#!/bin/bash

set -x -e

export LIBRARY_PATH="${PREFIX}/lib"
cp igfinder.py ${LIBRARY_PATH}

export BINARY_HOME="${PREFIX}/bin"
script=${BINARY_HOME}/igfinder

echo "#!/bin/bash" > $script
echo "python2 ${LIBRARY_PATH}/igfinder.py \$@" >> $script
