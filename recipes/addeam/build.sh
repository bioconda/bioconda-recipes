#!/usr/bin/env bash
set -e

export CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/htslib"
export LDFLAGS="-L${PREFIX}/lib -lhts -lgsl -lcurl -lgslcblas -llzma -lbz2 -lz  -lpthread"

pushd submodules/lib/libgab
git submodule update --init --recursive
make clean
make libgab.a
make -C gzstream
popd

pushd submodules/src
make clean
make CXX="${CXX}"   
install -v -m 0755 bam2prof "${PREFIX}/bin/"
install -v -m 0755 diffprof "${PREFIX}/bin/"
popd

install -v -m 0755 addeam-bam2prof.py addeam-cluster.py "${PREFIX}/bin/"
