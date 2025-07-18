#!/bin/bash
set -ex

mkdir -p "${PREFIX}/bin"

if [[ "$(uname -s)" == "Darwin" ]]; then
	sed -i.bak 's|-lomp|-L$(PREFIX)/lib -lomp|' Makefile
	rm -rf *.bak
fi

make CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 faprefix.sh gaf2paf gaf2unstable gaffilter \
	mzgaf2paf paf2lastz paf2stable pafcoverage pafmask \
	rgfa-split rgfa2paf "${PREFIX}/bin"
