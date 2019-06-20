#!/bin/bash
DATA_DIR="$PREFIX/bin/data/"
mkdir -p $DATA_DIR

$PREFIX/bin/src/group_humann2_uniref_abundances_to_GO_download_datasets.sh \
    "$DATA_DIR/go.obo" \
    "$DATA_DIR/goslim_metagenomics.obo" \
    "$DATA_DIR/map_infogo1000_uniref50.txt"