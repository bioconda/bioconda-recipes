#!/bin/bash
set -eu

mkdir -p $PREFIX/bin
chmod a+x bin/featureCounts
cp bin/featureCounts $PREFIX/bin/
