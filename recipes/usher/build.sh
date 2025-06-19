#!/bin/bash
set -ex
mkdir -p "${PREFIX}/bin"

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$OSTYPE" == "darwin"* ]]; then
    curl -sSLO https://github.com/oneapi-src/oneTBB/releases/download/2019_U9/tbb2019_20191006oss_mac.tgz
    tar -xzf tbb2019_20191006oss_mac.tgz
    export tbb_root="tbb2019_20191006oss"
else
    curl -sSLO https://github.com/oneapi-src/oneTBB/archive/2019_U9.tar.gz
    tar -xzf 2019_U9.tar.gz
    export tbb_root="oneTBB-2019_U9"
fi

if [[ `(uname -s)` == "Darwin" ]]; then
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
    export CONFIG_ARGS=""
fi

mkdir -p build
pushd build

cmake -S .. -B . -G Ninja -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DTBB_DIR="$(pwd)/../${tbb_root}" -DCMAKE_PREFIX_PATH="$(pwd)/../${tbb_root}/cmake" \
    -DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" -Wno-dev -Wno-deprecated --no-warn-unused-cli \
    -DCMAKE_CXX_COMPILER="${CXX}" -DBOOST_ROOT="${PREFIX}" "${CONFIG_ARGS}"

if [[ "$OSTYPE" == "darwin"* ]]; then
    # omit ripples-fast due to problems building on Mac
    make usher matUtils matOptimize usher-sampled ripples -j"${CPU_COUNT}"
    cat > ripples-fast <<EOF
#!/bin/bash
# This is a placeholder for the program ripples-fast on Mac where the build is currently failing.
# This is only a temporary workaround until we can fix ripples-fast, so that the rest of the
# programs in the usher package are not held back.

echo ""
echo "Sorry, ripples-fast is temporarily unavailable from bioconda for Mac."
echo "Please chime in on https://github.com/yatisht/usher/issues/310 if this inconveniences you."
echo ""
EOF
    chmod a+x ripples-fast
else
    ninja -j"${CPU_COUNT}"
fi

install -v -m 755 usher* mat* transpose* ripples* compareVCF check_samples_place "${PREFIX}/bin"

if [[ -d ./tbb_cmake_build ]]; then
    cp -rf ./tbb_cmake_build/tbb_cmake_build_subdir_release/* ${PREFIX}/lib/
elif [[ "$OSTYPE" == "darwin"* ]]; then
    cp -rf ../$tbb_root/lib/* ${PREFIX}/lib/
fi

popd
