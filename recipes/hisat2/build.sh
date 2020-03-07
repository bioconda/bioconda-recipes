#!/bin/bash

mkdir -p ${PREFIX}/bin

make CC=${CC} CPP=${CXX}

if [ $PY3K -eq 1 ]
then	
    2to3 --write *.py \	
        hisatgenotype_modules/*.py \	
        hisatgenotype_scripts/*.py
fi

# copy binaries and python scripts
for i in \
    hisat2 \
    hisat2-align-l \
    hisat2-align-s \
    hisat2-build \
    hisat2-build-l \
    hisat2-build-s \
    hisat2-inspect \
    hisat2-inspect-l \
    hisat2-inspect-s \
    *.py;
do
    cp ${i} ${PREFIX}/bin
    chmod +x ${PREFIX}/bin/${i}
done

# modules needed in PYTHONPATH
for i in hisatgenotype_modules/*.py;
do
   cp ${i} ${PREFIX}/lib/python${PY_VER}/site-packages
done
