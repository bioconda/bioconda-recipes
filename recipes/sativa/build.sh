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
install -d ${PREFIX}/bin

if [ $DARWIN -eq 1 ]; then
  install sativa.cfg *.py ${PREFIX}
else
  install -t ${PREFIX} *.py sativa.cfg
fi

# Place a symlink to sativa.py in bin/
( cd ${PREFIX}/bin; ln -s ../sativa.py . )

mkdir ${PREFIX}/raxml
cp ./raxml/raxmlHPC8* ./raxml/*.sh ${PREFIX}/raxml

cp -r ./epac ${PREFIX}
cp -r ./tests ${PREFIX}
cp -r ./example ${PREFIX}

