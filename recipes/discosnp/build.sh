#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration -Wno-incompatible-function-pointer-types"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-deprecated-declarations"

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
sed -i.bak 's/make -j8/make -j1/' INSTALL

# remove tests because of too much RAM needed
sed -i.bak 's/. .\/simple_test\.sh/#. .\/simple_test\.sh/' INSTALL

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

# change run_discoSnp++.sh deps path
sed -i.bak 's|\$EDIR/bin|\$EDIR|' run_discoSnp++.sh
sed -i.bak 's|scripts/|../scripts/|' run_discoSnp++.sh
sed -i.bak 's|\$EDIR/bin|\$EDIR|' run_discoSnp++_ML.sh

sed -i.bak 's|\$EDIR/../bin|\$EDIR|' discoSnpRAD/run_discoSnpRad.sh
sed -i.bak 's|\$EDIR/clustering_scripts/|\$EDIR/../discoSnpRAD/clustering_scripts/|' discoSnpRAD/run_discoSnpRad.sh

sed -i.bak 's|\$EDIR/../bin|\$EDIR|' discoSnpRAD/run_discoSnpRad.sh
sed -i.bak 's|\$EDIR/clustering_scripts/|../discoSnpRAD/clustering_scripts/|' discoSnpRAD/run_discoSnpRad.sh

rm -f *.bak
rm -f discoSnpRAD/*.bak

# copy binaries
install -v -m 0755 run_discoSnp++.sh run_discoSnp++_ML.sh discoSnpRAD/run_discoSnpRad.sh ${PREFIX}/bin

# copy binaries
install -v -m 0755 build/bin/read_file_names build/bin/kissnp2 build/bin/kissreads2 build/bin/quick_hierarchical_clustering ${PREFIX}/bin

# copy scripts directory
cp -Rf scripts ${PREFIX}
cp -Rf discoSnpRAD ${PREFIX}

# apply exec permissions
chmod +x ${PREFIX}/scripts/*.sh
chmod +x ${PREFIX}/discoSnpRAD/clustering_scripts/*.sh
