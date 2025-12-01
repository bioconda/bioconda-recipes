#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-deprecated-declarations"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration -Wno-incompatible-function-pointer-types -Wno-deprecated-declarations"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p ${PREFIX}/bin

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

if [[ `uname -s` == "Darwin" ]]; then
	export MACOSX_DEPLOYMENT_TARGET=11.0
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

# decrease RAM needed
sed -i.bak 's/make -j/make -j1/' INSTALL
sed -i.bak 's/2> log_linker_err//' test/simple_test.sh

# change run_discoSnp++.sh deps path
sed -i.bak 's|\$EDIR/bin|\$EDIR|' short_read_connector_linker.sh
sed -i.bak 's|\$EDIR/bin|\$EDIR|' short_read_connector_counter.sh

# remove precompiled binary for dsk
sed -i.bak 's|\$EDIR/thirdparty/dsk/bin/linux/dsk|dsk|' short_read_connector_linker.sh
sed -i.bak 's|\$EDIR/thirdparty/dsk/bin/macosx/dsk|dsk|' short_read_connector_linker.sh
# comment out chmod command for precompiled binary for dsk
sed -i.bak 's/^chmod/# chmod/' short_read_connector_linker.sh

# remove precompiled binary for dsk
sed -i.bak 's|\$EDIR/thirdparty/dsk/bin/linux/dsk|dsk|' short_read_connector_counter.sh
sed -i.bak 's|\$EDIR/thirdparty/dsk/bin/macosx/dsk|dsk|' short_read_connector_counter.sh
# comment out chmod command for precompiled binary for dsk
sed -i.bak 's/^chmod/# chmod/' short_read_connector_counter.sh

rm -f *.bak

rm -rf thirdparty/gatb-core
git clone https://github.com/GATB/gatb-core.git thirdparty/gatb-core

cd thirdparty/gatb-core
git checkout e80aa72fc91bac58de11341b536c3a94ecb54719
cd ../..

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="$CXX" \
	-DCMAKE_C_COMPILER="$CC" \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCPPUNIT_INCLUDE_DIR="${PREFIX}/include" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build -j "${CPU_COUNT}"

# copy binaries
install -v -m 0755 short_read_connector_counter.sh short_read_connector_linker.sh "${PREFIX}/bin"

# copy external bin
install -v -m 0755 build/bin/* "${PREFIX}/bin"
