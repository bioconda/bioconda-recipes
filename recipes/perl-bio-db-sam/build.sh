#!/bin/bash

export SAMTOOLS="$PREFIX"
HOME=/tmp cpanm -i --build-args='--config lddlflags=-shared' .
