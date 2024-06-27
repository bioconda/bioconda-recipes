#!/bin/sh
set -x -e
mkdir -p ${PREFIX}/bin
cp -rf * ${PREFIX}/bin
cd ${PREFIX}/bin
