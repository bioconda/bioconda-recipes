#!/bin/bash

# flag installer that no external packages should be installed
# they are all installed by conda dependencies
export SKIP_EXTERNAL=1

# install ORTHOLOGER and BRHCLUS
# * $PREFIX/bin/ORTHOLOGER-x.x.x/
# * $PREFIX/bin/orthologer    -> softlink to ORTHOLOGER-x.x.x
# * $PREFIX/bin/brhclus       -> plus all the other executables of BRHCLUS
./install_pkg.sh
