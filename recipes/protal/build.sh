#!/bin/bash
set -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

rm -rf cmake-build-release

export VERBOSE=1

if [[ $(uname -s) == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

# CMakeLists.txt hardcodes the two x86 ISA levels the protal/protal_avx2 pair is
# built for. On arm both collapse to the baseline armv8 target.
case $(uname -m) in
    aarch64|arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|g' CMakeLists.txt
	sed -i.bak 's|-march=x86-64|-march=armv8-a|g' CMakeLists.txt
	rm -f CMakeLists.txt.bak
	;;
esac

# Deliberately no -march here: the per-target isa_baseline / isa_avx2 interface
# libraries in CMakeLists.txt set it. Adding -march=x86-64-v3 globally would
# also apply it to the vendored libraries (wfa2, cPMML, gzstream), which are
# linked into the baseline binary too and would then crash on pre-AVX2 CPUs.
cmake -S . -B cmake-build-release -G Ninja \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

# Only the targets we ship. The *_static targets in CMakeLists.txt are for
# upstream's standalone release builds and are not packaged here.
ninja -C cmake-build-release -j "${CPU_COUNT}" \
	protal protal_avx2 simulate_metagenomes

install -v -m 0755 cmake-build-release/protal               "${PREFIX}/bin/protal_plain"
install -v -m 0755 cmake-build-release/protal_avx2          "${PREFIX}/bin/protal_avx2"
install -v -m 0755 cmake-build-release/simulate_metagenomes "${PREFIX}/bin/simulate_metagenomes"

# protal itself is the launcher, which picks protal_avx2 or protal_plain per CPU.
install -v -m 0755 protal_launcher "${PREFIX}/bin/protal"

# Ship only the user-facing entry points, each installed without a file
# extension. Deliberately not a scripts/* glob: that would also drop R sources,
# docs, a subdirectory, a 10 MB PMML model and the model-training helpers into
# ${PREFIX}/bin.
install -v -m 0755 scripts/protal_map_utils     "${PREFIX}/bin/protal_map_utils"
install -v -m 0755 scripts/protal_profile_utils "${PREFIX}/bin/protal_profile_utils"
install -v -m 0755 scripts/qcmsa.py             "${PREFIX}/bin/qcmsa"
