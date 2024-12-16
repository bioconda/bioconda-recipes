#!/bin/bash

# flag installer that no external packages should be installed
# they are all installed by conda dependencies
export SKIP_EXTERNAL=1

# install ORTHOLOGER and BRHCLUS
./install_pkg.sh
