#!/usr/bin/env bash

set -xe

# Install as plink
mkdir -p $PREFIX/bin
install -v -m 0755 plink $PREFIX/bin/