#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -L${PREFIX}/lib -fPIC -Wno-deprecated-declarations"
export CXXFLAGS="${CXXFLAGS} -O3"

2to3 -w build-common/python/*.py
2to3 -w integration-test/breakdancer_test.py

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


if [[ "$(uname -s)" == "Darwin" ]]; then
	# for Mac OSX
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -Wl,-dead_strip_dylibs -headerpad_max_install_names"
fi

# To run boost linking $CC and $CXX to gcc and g++
if [[ `uname -s` == "Darwin" ]]; then
	ln -sf ${CC} ${PREFIX}/bin/clang
	ln -sf ${CXX} ${PREFIX}/bin/clang++
else
	ln -sf ${CC} ${PREFIX}/bin/gcc
	ln -sf ${CXX} ${PREFIX}/bin/g++
fi

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCMAKE_C_COMPILER="$CC" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cd build
make
make install

# Make bam2cfg.pl work from bin; it needs some modules from lib.
BAM2CFG_LIB=`dirname $( find ${PREFIX}/lib -name "bam2cfg.pl" )`
${PREFIX}/bin/sed -i'' "s@use AlnParser;@use lib \"${BAM2CFG_LIB}\";\nuse AlnParser;@" ${BAM2CFG_LIB}/bam2cfg.pl
ln -s ${BAM2CFG_LIB}/bam2cfg.pl ${PREFIX}/bin

# copy samtools to bin
install -v -m 0755 vendor/samtools/samtools ${PREFIX}/bin

# Remove the fake links
if [[ `uname -s` == "Darwin" ]]; then
	rm -rf ${PREFIX}/bin/clang
	rm -rf ${PREFIX}/bin/clang++
else
	rm -rf ${PREFIX}/bin/gcc
	rm -rf ${PREFIX}/bin/g++
fi
