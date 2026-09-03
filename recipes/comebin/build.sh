#!/usr/bin/env bash

mkdir -p "$PREFIX/bin"

cp -r COMEBin $PREFIX/bin/
chmod a+x auxiliary/*

cp -r auxiliary $PREFIX/bin/

install -v -m 0755 COMEBin/scripts/print_comment.py "$PREFIX/bin"
install -v -m 0755 COMEBin/scripts/gen_cov_file.sh "$PREFIX/bin"
install -v -m 0755 COMEBin/run_comebin.sh "$PREFIX/bin"
