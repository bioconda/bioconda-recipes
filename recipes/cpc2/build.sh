#!/bin/bash
set -eu

mkdir -p ${PREFIX}/bin
chmod a+x bin/*
cp bin/* ${PREFIX}/bin/

mkdir -p ${PREFIX}/data
chmod a+tx data/*
cp data/* ${PREFIX}/data/
