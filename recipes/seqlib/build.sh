#!/bin/bash
set -eu -o pipefail

sed -i 's|SUBDIRS = bwa htslib fermi-lite src|SUBDIRS = fermi-lite src|' Makefile.am
sed -i 's|SUBDIRS = bwa htslib fermi-lite src|SUBDIRS = fermi-lite src|' Makefile.in

sed -i 's|mkdir -p bin \&\& cp src/libseqlib.a fermi-lite/libfml.a bwa/libbwa.a htslib/libhts.a bin|mkdir -p bin \&\& cp src/libseqlib.a fermi-lite/libfml.a bin|' Makefile.am
sed -i 's|mkdir -p bin \&\& cp src/libseqlib.a fermi-lite/libfml.a bwa/libbwa.a htslib/libhts.a bin|mkdir -p bin \&\& cp src/libseqlib.a fermi-lite/libfml.a bin|' Makefile.in

./configure
make
make install
make seqtools

mkdir -p ${PREFIX}/bin
cp bin/seqtools ${PREFIX}/bin/

mkdir -p ${PREFIX}/lib
cp lib/libseqlib.a ${PREFIX}/lib/
