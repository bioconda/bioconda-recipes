#!/bin/bash

curl -L https://github.com/samtools/samtools/archive/0.1.19.tar.gz > 0.1.19.tar.gz
tar -xzf 0.1.19.tar.gz

export SAMTOOLS_ROOT=samtools-0.1.19

make
