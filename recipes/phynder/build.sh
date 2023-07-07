#!/bin/bash
set -x
set +e

git clone https://github.com/samtools/htslib.git
cd htslib
make lib-static htslib_static.mk

cd -

sed 's#HTSDIR=../htslib#HTSDIR=./htslib#g'
make
make install
