#!/bin/bash
set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    ..

make -j"${CPU_COUNT}"

mkdir -p "${PREFIX}/bin" "${PREFIX}/lib"
for exe in PanGenie PanGenie-index PanGenie-vcf PanGenie-sampling Analyze-UK; do
    install -m 0755 "src/${exe}" "${PREFIX}/bin/${exe}"
done

install -m 0644 src/libPanGenieLib.so "${PREFIX}/lib/"

