#!/bin/bash
set -euo pipefail
./configure --prefix=$PREFIX
make
make install


