#!/bin/sh
set -e

echo "Building viralverify..."

cp -r $SRC_DIR/* $PREFIX/
#mkdir $PREFIX/bin
cd $PREFIX/
#ln -s ../viralverify.py viralverify
#ln -s ../training_script.py viralverify_training

chmod +x viralverify.py
chmod +x training_script.py
