#!/usr/bin/env bash

Rscript --vanilla /opt/anaconda1anaconda2anaconda3/cluster_analysis/bin/SCRAMble.R \
  --install-dir /opt/anaconda1anaconda2anaconda3/cluster_analysis/bin \
  --mei-refs /opt/anaconda1anaconda2anaconda3/cluster_analysis/resources/MEI_consensus_seqs.fa \
  "$@"
