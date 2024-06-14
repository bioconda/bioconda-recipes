#!/bin/bash
set -eu

mkdir -p $PREFIX/bin
ls
cp impute5_v1.1.5/impute5_1.1.5_static $PREFIX/bin/impute5
cp impute5_v1.1.5/imp5Chunker_1.1.5_static $PREFIX/bin/imp5Chunker
cp impute5_v1.1.5/imp5Converter_1.1.5_static $PREFIX/bin/imp5Converter
