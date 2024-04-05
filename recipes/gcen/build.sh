#!/usr/bash
set -x
mkdir -p "$PREFIX"/bin
make
mv bin/* "$PREFIX"/bin/
mv util/* "$PREFIX"/bin/
