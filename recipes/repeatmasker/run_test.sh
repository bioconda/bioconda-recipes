#!/bin/bash -e

INPUT=rm_input1.fasta
OUTPUT=${INPUT}.masked

RepeatMasker -lib sample_repeats.fasta $INPUT

if [[ -f $OUTPUT ]] ; then
  if md5sum --quiet --check test_md5.txt ; then
      exit 0
  else
      exit 1
  fi
else
  exit 1
fi
