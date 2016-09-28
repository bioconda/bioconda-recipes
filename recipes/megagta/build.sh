#!/bin/bash
sh make.sh
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
