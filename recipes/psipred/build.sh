#!/bin/bash

mkdir -p "${PREFIX}/share/${PKG_NAME}/data"
install -m 644 data/* "${PREFIX}/share/${PKG_NAME}/data"
mkdir -p "${PREFIX}/bin"
rm bin/*

pushd src
sed -i '/CC.*= cc/d' Makefile
sed -i \
    -e '1i#include <stdlib.h>' \
    -e '/^void[[:space:]]\+\*calloc.*malloc.*;/d' \
    -e 's|main|int main|' \
    sspred_avpred.c
make -j "${CPU_COUNT}"
make install
popd
install -m 755 bin/* "${PREFIX}/bin"

sed -i \
  -e 's|#!/bin/tcsh|#!/usr/bin/env tcsh|' \
  -e 's|set execdir = ./bin|set execdir = $CONDA_PREFIX/bin|' \
  -e 's|set datadir = ./data|set datadir = $CONDA_PREFIX/share/psipred/data|' \
  runpsipred_single

sed -i \
  -e 's|#!/bin/tcsh|#!/usr/bin/env tcsh|' \
  -e 's|set ncbidir = /usr/local/bin|set ncbidir = $CONDA_PREFIX/bin|' \
  -e 's|set execdir = ./bin|set execdir = $CONDA_PREFIX/bin|' \
  -e 's|set datadir = ./data|set datadir = $CONDA_PREFIX/share/psipred/data|' \
  runpsipred

sed -i \
  -e 's|#!/bin/tcsh|#!/usr/bin/env tcsh|' \
  -e 's|set ncbidir = /usr/local/bin|set ncbidir = $CONDA_PREFIX/bin|' \
  -e 's|set execdir = ../bin|set execdir = $CONDA_PREFIX/bin|' \
  -e 's|set datadir = ../data|set datadir = $CONDA_PREFIX/share/psipred/data|' \
  BLAST+/runpsipredplus

install -m 755 runpsipred_single runpsipred BLAST+/runpsipredplus "${PREFIX}/bin"
