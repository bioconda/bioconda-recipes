#!/bin/bash
set -eu

mkdir -p $PREFIX/bin
chmod a+x sambamba_v*
cp sambamba_v* $PREFIX/bin/sambamba
