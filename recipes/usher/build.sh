#!/bin/bash
#/System/Volumes/Data/System/DriverKit/usr/lib/libSystem.dylib
mkdir -p $PREFIX/bin

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$OSTYPE" == "darwin"* ]]; then
    curl -sSLO https://github.com/oneapi-src/oneTBB/releases/download/2019_U9/tbb2019_20191006oss_mac.tgz
    tar -xzf tbb2019_20191006oss_mac.tgz
    tbb_root="tbb2019_20191006oss"
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
    curl -sSLO https://github.com/oneapi-src/oneTBB/archive/2019_U9.tar.gz
    tar -xzf 2019_U9.tar.gz
    tbb_root="oneTBB-2019_U9"
    export CONFIG_ARGS=""
fi

mkdir -p build
pushd build

cmake -S .. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DTBB_DIR=${PWD}/../$tbb_root \
    -DCMAKE_PREFIX_PATH=${PWD}/../$tbb_root/cmake \
    "${CONFIG_ARGS}"

if [[ "$OSTYPE" == "darwin"* ]]; then
    # omit ripples-fast due to problems building on Mac
    make -j"${CPU_COUNT}" usher matUtils matOptimize usher-sampled ripples
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
    cmake --build . --target install -j "${CPU_COUNT}"
fi

install -v -m 0755 ./usher ${PREFIX}/bin/
install -v -m 0755 ./matUtils ${PREFIX}/bin/
install -v -m 0755 ./matOptimize ${PREFIX}/bin/
if [[ -f "usher-sampled" ]]; then
    install -v -m 0755 ./usher-sampled ${PREFIX}/bin/
fi
if [[ -f "ripples" ]]; then
    install -v -m 0755 ./ripples ${PREFIX}/bin/
fi
if [[ -f "ripples-fast" ]]; then
    install -v -m 0755 ./ripples-fast ${PREFIX}/bin/
fi
if [ -d ./tbb_cmake_build ]; then
    cp -rf ./tbb_cmake_build/tbb_cmake_build_subdir_release/* ${PREFIX}/lib/
elif [[ "$OSTYPE" == "darwin"* ]]; then
    cp -rf ../$tbb_root/lib/* ${PREFIX}/lib/
fi

popd
