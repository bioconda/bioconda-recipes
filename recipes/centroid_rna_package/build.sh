#!/usr/bin/env bash

BINARY_HOME=$PREFIX/bin

cd $SRC_DIR

for i in centroid_homfold centroid_fold centroid_alifold
do
    cp $i $BINARY_HOME;
    chmod +x $i;
done