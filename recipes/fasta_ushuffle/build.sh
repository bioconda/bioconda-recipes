#!/bin/bash

mkdir -p ${PREFIX}/bin
make CC=$CC
cp fasta_ushuffle ushuffle ${PREFIX}/bin
