#!/bin/bash

export LD_LIBRARY_PATH="$PREFIX/lib:$PREFIX/lib/x86_64-linux-gnu:$LD_LIBRARY_P‌​ATH"
make
mkdir -p "$PREFIX/bin"
cp tadaridaD "$PREFIX/bin"