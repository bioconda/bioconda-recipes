#!/bin/bash

set -ex

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/share/man/man1"

make z_dyn=1 hts_dyn=1 release

make install

