#!/bin/bash

export USE_AVX=yes
export USE_AVX2=yes

make -C ./raxml CC="$CC"

install -d ${PREFIX}/tmp
install -t ${PREFIX} *.py ./raxml/raxmlHPC8* ./raxml/*.sh 

co -r ./epac ${PREFIX}

