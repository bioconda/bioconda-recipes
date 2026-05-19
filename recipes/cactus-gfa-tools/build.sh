#!/bin/bash
set -ex

mkdir -p "${PREFIX}/bin"

make -j"${CPU_COUNT}"

install -v -m 0755 faprefix.sh gaf2paf gaf2unstable gaffilter \
	mzgaf2paf paf2lastz paf2stable pafcoverage pafmask \
	rgfa-split rgfa2paf "${PREFIX}/bin"
