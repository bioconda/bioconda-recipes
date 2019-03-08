#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $HOME/$PKG_NAME

cp -R $SP_DIR/$PKG_NAME $HOME/$PKG_NAME
