#!/usr/bin/env bash

mkdir -p $PREFIX/bin/ 
cp -r COMEBin $PREFIX/bin/
chmod a+x auxiliary/*
cp -r auxiliary $PREFIX/bin/
chmod a+x COMEBin/scripts/gen_cov_file.sh
cp COMEBin/scripts/gen_cov_file.sh $PREFIX/bin/
chmod a+x COMEBin/scripts/print_comment.py
cp COMEBin/scripts/print_comment.py $PREFIX/bin/
chmod a+x bin/run_comebin.sh
cp bin/run_comebin.sh $PREFIX/bin/

