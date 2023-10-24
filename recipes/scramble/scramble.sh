#!/usr/bin/env bash

Rscript --vanilla /opt/anaconda1anaconda2anaconda3/share/scramble/bin/SCRAMble.R \
  --install-dir /opt/anaconda1anaconda2anaconda3/share/scramble/bin \
  --mei-refs /opt/anaconda1anaconda2anaconda3/share/scramble/resources/MEI_consensus_seqs.fa \
  "$@"
