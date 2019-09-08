#!/bin/bash
set -e -x
mkdir -p $PREFIX/bin

chmod 755 bin/illumina-cleanup
cp -f bin/illumina-cleanup $PREFIX/bin/illumina-cleanup
