#!/bin/bash

export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_P‌​ATH"
make
mkdir -p "$PREFIX/bin"
cp tadaridaD "$PREFIX/bin"