#!/bin/bash

export USE_AVX=yes
export USE_AVX2=yes

case `uname` in
Darwin) export DARWIN=1;;
Linux) export DARWIN=0;;
*) echo "Unknown architecture"; exit 1;;
esac

make -C ./raxml CC="$CC"

install -d ${PREFIX}/tmp
install -t ${PREFIX} *.py ./raxml/raxmlHPC8* ./raxml/*.sh 

cp -r ./epac ${PREFIX}
cp -r ./tests ${PREFIX}
cp -r ./example ${PREFIX}

