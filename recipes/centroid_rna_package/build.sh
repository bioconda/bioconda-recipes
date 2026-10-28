#!/usr/bin/env bash

mkdir -p ${PREFIX}/bin

for i in centroid_homfold centroid_fold centroid_alifold
do
    cp $i ${PREFIX}/bin
done
chmod +x ${PREFIX}/bin/*
