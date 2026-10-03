#!/bin/bash

./configure --prefix=$PREFIX PERL=`command -v perl`
make
make install

