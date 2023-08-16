#!/bin/bash

export USE_AVX=yes
export USE_AVX2=yes

shopt -s expand_aliases
alias gcc=$GCC
alias

make -C ./raxml

install -d ${PREFIX}/tmp
install -t ${PREFIX} *.py ./raxml/raxmlHPC8* ./raxml/*.sh ./epac/*

