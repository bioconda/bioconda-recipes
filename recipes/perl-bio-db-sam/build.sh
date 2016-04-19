#!/bin/bash
export SAMTOOLS=$PREFIX/lib
cpanm -i --build-args='--config lddlflags=-shared' .
