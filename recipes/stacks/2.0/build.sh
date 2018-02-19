#!/bin/bash

./configure --prefix=$PREFIX --enable-bam
make
make install
