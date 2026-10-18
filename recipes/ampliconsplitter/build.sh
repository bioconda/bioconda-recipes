#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

cd src

case $(uname -m) in
	aarch64) sed -i.bak 's|-march=x86-64|-march=armv8-a|' CMakeLists.txt && sed -i.bak 's|-march=x86-64|-march=armv8-a|' HS_GenomeTailor/CMakeLists.txt ;;
	arm64) sed -i.bak 's|-march=x86-64|-march=armv8.4-a|' CMakeLists.txt && sed -i.bak 's|-march=x86-64|-march=armv8.4-a|' HS_GenomeTailor/CMakeLists.txt ;;
	x86_64) sed -i.bak 's|-march=x86-64|-march=x86-64-v3|' CMakeLists.txt && sed -i.bak 's|-march=x86-64|-march=x86-64-v3|' HS_GenomeTailor/CMakeLists.txt ;;
esac

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

ninja -C build -j "${CPU_COUNT}"

install -v -m 0755 build/HS_call_variants build/HS_create_new_contigs \
	build/HS_fa2gfa build/HS_gfa2fa build/HS_separate_reads \
	build/HS_GenomeTailor/HS_GenomeTailor cut_gfa.py \
	../ampliconsplitter.py "${PREFIX}/bin"

install -v -m 0755 GraphUnzip/*.py "${PREFIX}/bin"
