#!/bin/bash
gcc -o collect_mgf collect_mgf.c
cp collect_mgf $PREFIX/collect_mgf
chmod +x $PREFIX/collect_mgf