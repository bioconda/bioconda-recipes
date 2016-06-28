#!/bin/bash
set -euo pipefail
autoreconf -i -I /usr/share/aclocal
./configure --prefix=$PREFIX
make
make install
