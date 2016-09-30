#!/bin/bash
mkdir -p $PREFIX/bin
make release
cp stringtie $PREFIX/bin
