#!/bin/bash
 
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ./easel/devkit/sqc

./configure --prefix=$PREFIX
make -j 2
make check
make install
