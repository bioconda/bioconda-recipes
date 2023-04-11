#!/bin/sh
set -e

echo "Building viralverify..."

cp -r $SRC_DIR/* $PREFIX/

cd $PREFIX/bin

chmod +x viralverify
chmod +x training_script
