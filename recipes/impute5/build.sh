#!/bin/bash
set -eu

mkdir -p $PREFIX/bin
ls
cp impute5_v1.1.5/impute5 $PREFIX/bin
cp impute5_v1.1.5/imp5Chunker $PREFIX/bin
cp impute5_v1.1.5/imp5Converter $PREFIX/bin
