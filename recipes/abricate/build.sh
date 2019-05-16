#!/bin/bash

set -e
./bin/abricate --setupdb

mkdir -p $PREFIX/bin
cp -r * $PREFIX
