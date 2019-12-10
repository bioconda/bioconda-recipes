#!/bin/bash
set -e

gunzip ORFfinder.gz
mkdir -p ${PREFIX}/bin
cp ORFfinder ${PREFIX}/bin
chmod a+x $PREFIX/bin/ORFfinder
