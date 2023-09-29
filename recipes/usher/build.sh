#!/bin/bash
#/System/Volumes/Data/System/DriverKit/usr/lib/libSystem.dylib
mkdir -p $PREFIX/bin


if [[ "$OSTYPE" == "darwin"* ]]; then
    curl -sSLO https://github.com/oneapi-src/oneTBB/releases/download/2019_U9/tbb2019_20191006oss_mac.tgz
    tar -xzf tbb2019_20191006oss_mac.tgz
    tbb_root=tbb2019_20191006oss
else
    curl -sSLO https://github.com/oneapi-src/oneTBB/archive/2019_U9.tar.gz
    tar -xzf 2019_U9.tar.gz
    tbb_root=oneTBB-2019_U9
fi

mkdir -p build
pushd build

cmake -DTBB_DIR=${PWD}/../$tbb_root -DCMAKE_PREFIX_PATH=${PWD}/../$tbb_root/cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..

if [[ "$OSTYPE" == "darwin"* ]]; then
    # omit ripples-fast due to problems building on Mac
    make -j 1 usher matUtils matOptimize usher-sampled ripples
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
    make -j 1
fi

cp ./usher ${PREFIX}/bin/
cp ./matUtils ${PREFIX}/bin/
cp ./matOptimize ${PREFIX}/bin/
if [ -f "usher-sampled" ]; then
    cp ./usher-sampled ${PREFIX}/bin/
fi
if [ -f "ripples" ]; then
    cp ./ripples ${PREFIX}/bin/
fi
if [ -f "ripples-fast" ]; then
    cp ./ripples-fast ${PREFIX}/bin/
fi
if [ -d ./tbb_cmake_build ]; then
    cp ./tbb_cmake_build/tbb_cmake_build_subdir_release/* ${PREFIX}/lib/
elif [[ "$OSTYPE" == "darwin"* ]]; then
    cp ../$tbb_root/lib/* ${PREFIX}/lib/
fi

popd
