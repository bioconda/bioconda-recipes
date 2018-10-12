#!/bin/bash

mkdir -p $PREFIX/bin

make
cp wtdbg2 wtdbg-cns wtpoa-cns $PREFIX/bin
