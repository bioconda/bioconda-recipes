#!/bin/bash

# https://bioconda.github.io/troubleshooting.html#zlib-errors

mkdir -p ${PREFIX}/bin
chmod +x ./bin/*
mv ./bin/* ${PREFIX}/bin/
