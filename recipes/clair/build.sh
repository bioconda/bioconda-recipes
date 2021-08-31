#!/bin/bash

mkdir -pv $PREFIX/bin
cp -rv clair dataPrepScripts shared $PREFIX/bin
cp clair.py $PREFIX/bin/
