#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-register"

install -d "${PREFIX}/bin"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

sed -i.bak 's/-f .\/samtools-0.1.19\/libbam.a/1/' Makefile
sed -i.bak 's/\$WD\/samtools-0.1.19\/samtools/samtools/' psiclass

# Fix perl shebang
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' *.pl
rm -f *.bak

make CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS} -Wformat -O3" \
	LINKPATH="${LDFLAGS} -I./samtools-0.1.19"

install -v -m 0755 psiclass \
	classes \
	junc \
	trust-splice \
	subexon-info \
	combine-subexons \
	vote-transcripts \
	add-genename \
	FilterSplice.pl \
	"${PREFIX}/bin"
