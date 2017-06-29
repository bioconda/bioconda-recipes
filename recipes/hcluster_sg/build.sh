#!/bin/sh
set -e

make
mkdir -p "$PREFIX/bin"
cp hcluster_sg "$PREFIX/bin/"
