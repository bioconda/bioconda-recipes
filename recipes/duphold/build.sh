#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin
chmod a+x duphold
cp duphold $PREFIX/bin
