#!/bin/bash

mkdir -p $PREFIX/bin

chmod +x src/*.pl
cp src/deltaBS.pl $PREFIX
cp src/buildCustomModels.pl $PREFIX

