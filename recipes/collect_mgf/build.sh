#!/bin/bash
gcc -o collect_mgf collect_mgf.c
mkdir -p $PREFIX/bin
cp collect_mgf $PREFIX/bin/collect_mgf
chmod +x $PREFIX/bin/collect_mgf