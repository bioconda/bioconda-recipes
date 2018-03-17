#!/bin/bash
set -eu

./configure --prefix=$PREFIX --sysconfdir=$PREFIX
make
make install
