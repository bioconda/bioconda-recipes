#!/bin/bash
pushd autodock
./configure PREFIX=$PREFIX
make
make check
make install
