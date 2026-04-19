#!/usr/bin/env bash
set -eo pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export SHARE_PATH="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"

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
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

paras_model_link='https://zenodo.org/records/13165500/files/model.paras?download=1'
# q: if ./external_tools/paras/model.paras doesn't exist, download it
if [ ! -f "./external_tools/paras/model.paras" ]; then
    echo "Downloading model.paras from $paras_model_link..."
    mkdir -p ./external_tools/paras
    wget -O ./external_tools/paras/model.paras $paras_model_link
fi

cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

ninja -C build -j "${CPU_COUNT}"

install -v -m 0755 build/hmm_nrp_matcher "${PREFIX}/bin"

cp -rf * ${SHARE_PATH}/

ln -s ${SHARE_PATH}/nerpa.py ${PREFIX}/bin/nerpa.py
ln -s ${SHARE_PATH}/nerpa.py ${PREFIX}/bin/nerpa
