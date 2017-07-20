#!/bin/bash
set -o nounset -o pipefail -o errexit
set -o xtrace

mkdir -p $PREFIX/bin
chmod +x bin/*
cp bin/* $PREFIX/bin
