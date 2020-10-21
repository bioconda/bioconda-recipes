#!/bin/bash

mkdir -pv "${PREFIX}"/bin
cp -p $(find ./ -maxdepth 1 -name "*mga_osx" -o -name "*mga_linux_ia64") "${PREFIX}"/bin/mga
