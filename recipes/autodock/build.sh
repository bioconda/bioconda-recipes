#!/bin/bash
pushd autodock
alias csh=tsch
./configure PREFIX=$PREFIX
make
make check
make install
