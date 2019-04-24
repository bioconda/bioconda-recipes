#!/bin/bash

ln -s $PREFIX/include/bam/bam.h $PREFIX/include/bam.h

export SAMTOOLS="$PREFIX"
HOME=/tmp cpanm -i --build-args='--config lddlflags=-shared' .
