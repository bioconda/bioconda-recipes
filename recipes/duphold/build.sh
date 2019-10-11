#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin
chmod a+x duphold_static
cp duphold_static $PREFIX/bin/duphold
