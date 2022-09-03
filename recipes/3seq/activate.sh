#!/bin/bash

PVALUE_TABLE="${PREFIX}/share/3seq/PVT.3SEQ.2017.700";
export HOME=`env | grep HOME | cut -d= -f2`;
if [[ -e "${HOME}/Library/3seq/3seq.conf" ]]; then
    mv ${HOME}/Library/3seq/3seq.conf ${HOME}/Library/3seq/default.3seq.conf
else
    echo "${PVALUE_TABLE}" > ${HOME}/Library/3seq/default.3seq.conf
fi
echo "${PVALUE_TABLE}" > ${HOME}/Library/3seq/3seq.conf
