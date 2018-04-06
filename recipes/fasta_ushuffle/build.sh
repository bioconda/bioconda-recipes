#!/bin/bash

mkdir -p ${PREFIX}/bin
make
cp fasta_ushuffle ushuffle ${PREFIX}/bin
