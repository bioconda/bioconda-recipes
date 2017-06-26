#!/bin/bash
download_behst_data.sh
BINDIR=$(dirname $(readlink $(which project.sh)))
(
    cd $BINDIR &&
    project.sh ../data/pressto_LUNG_enhancers.bed DEFAULT_EQ DEFAULT_ET
)
