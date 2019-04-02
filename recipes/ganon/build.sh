#!/bin/bash

rm -r libs/*
git init
git config -f .gitmodules --get-regexp '^submodule\..*\.path$' | 
  while read path_key path; do
    url=$(git config -f .gitmodules --get "$(echo $path_key | sed 's/\.path/.url/')")
    branch=$(git config -f .gitmodules --get "$(echo $path_key | sed 's/\.path/.branch/')")
    if [[ ! -z $branch ]]; then branch="-b ${branch}"; fi
    git submodule add $branch $url $path
  done


mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make

ctest -VV .

mkdir -p ${PREFIX}/bin
cp ganon-build ganon-classify $PREFIX/bin/
