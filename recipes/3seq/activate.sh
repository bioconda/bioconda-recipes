#!/bin/bash

# Check if 3seq is already associated with a p value table
declare -i PTAB_COUNT
PTAB_COUNT=`3seq | grep "no p-value table" | wc -l`

# If no existing p value table exists then link to downloaded table
if [[ $PTAB_COUNT == 0 ]]; then
    yes | timeout 1 3seq -c $PREFIX/share/3seq/PVT.3SEQ.2017.700;
fi
