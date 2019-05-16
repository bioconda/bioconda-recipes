#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin
chmod a+x duphold_shared
cp duphold_shared $PREFIX/bin/duphold
