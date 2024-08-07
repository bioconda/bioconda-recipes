#!/bin/bash
set -exuo pipefail

cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${PREFIX}"
make install
