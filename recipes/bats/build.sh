#!/usr/bin/env bash

set -e

mkdir -p "$PREFIX"/{bin,libexec,share/man/man{1,7}}
cp -R bin/* "$PREFIX"/bin
cp -R libexec/* "$PREFIX"/libexec
cp man/bats.1 "$PREFIX"/share/man/man1
cp man/bats.7 "$PREFIX"/share/man/man7
