#!/bin/sh
set -e

echo "Building viralcomplete..."

cp -r $SRC_DIR/* $PREFIX/

cd $PREFIX/bin

chmod +x viralcomplete
