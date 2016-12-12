#!/bin/bash

set -o pipefail

cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$PREFIX
make
make install
