#!/bin/bash

cd $SRC_DIR
gunzip ORFfinder.gz
cp ORFfinder $PREFIX/bin
chmod a+x $PREFIX/bin/ORFfinder
