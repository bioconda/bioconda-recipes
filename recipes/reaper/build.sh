#!/bin/bash

cd src
make
mkdir -p $PREFIX/bin
cp minion reaper swan tally $PREFIX/bin
