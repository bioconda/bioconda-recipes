#!/usr/bin/env bash
mkdir -p $PREFIX/opt/feature_merge
cp -r . $PREFIX/opt/feature_merge
mkdir -p $PREFIX/bin
ln -s $PREFIX/opt/feature_merge/feature_merge.py $PREFIX/bin/feature_merge
chmod +x $PREFIX/bin/*
