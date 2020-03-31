#!/bin/bash

mkdir -p $PREFIX/bin/config_files
mkdir -p $PREFIX/config_files

cp bin/* $PREFIX/bin
cp plasmidID $PREFIX/bin

cp config_files/* $PREFIX/bin/config_files
