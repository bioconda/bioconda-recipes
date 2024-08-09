#!/bin/bash

set -x -e

dna-brnn 2>&1 | grep "Usage: dna-brnn" #-Ai attcc-alpha.knm -t16 test.fa > seq.bed

dna-cnn 2>&1 | grep "Usage: dna-cnn"

gen-fq 2>&1 | grep "Usage: gen-fq"

parse-rm.js 2>&1 | grep "Usage: k8 parse-rm"