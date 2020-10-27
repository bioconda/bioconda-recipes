#!/bin/bash
set -eu -o pipefail

sed -i 's@g++@$(CXX)@g' Makefile
make CXX=$CXX
mkdir "$PREFIX/bin"
cp  slimfastq "$PREFIX/bin"
cp  tools/slimfastq.multi "$PREFIX/bin"


