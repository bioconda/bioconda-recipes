#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

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

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/3seq

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"
ninja -C build -j"${CPU_COUNT}"

install -v -m 0755 build/3seq "${PREFIX}/bin"

wget -P $PREFIX/share/3seq/ https://www.dropbox.com/s/zac4wotgdmm3mvb/pvaluetable.2017.700.tgz
tar xfz $PREFIX/share/3seq/pvaluetable.2017.700.tgz -C $PREFIX/share/3seq/
echo "yes | 3seq -c $PREFIX/share/3seq/PVT.3SEQ.2017.700" > pval_check.sh; chmod +x pval_check.sh; (timeout 5 ./pval_check.sh &> log.out & exit 0)
