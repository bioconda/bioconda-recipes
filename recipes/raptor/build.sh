#!/bin/bash

set -eux

get_instruction_set_flags() {
    local instruction_set="$1"
    case "${instruction_set}" in
        none)
            echo ""
            ;;
        sse2)
            echo "-msse2"
            ;;
        sse4.2)
            echo "-msse4.2"
            ;;
        avx2)
            echo "-mavx2"
            ;;
        avx512)
            echo "-mavx512f -mavx512bw"
            ;;
        *)
            echo "Unknown instruction set: ${instruction_set}" >&2
            exit 1
            ;;
    esac
}

for INSTRUCTION_SET in "none" "sse2" "sse4.2" "avx2" "avx512"; do
    mkdir -p build/${INSTRUCTION_SET}
    cd build/${INSTRUCTION_SET}
    cmake ../.. -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_CXX_FLAGS="$(get_instruction_set_flags ${INSTRUCTION_SET}) -Wno-interference-size -D__STDC_FORMAT_MACROS" \
                -DRAPTOR_NATIVE_BUILD=OFF \
                -DCMAKE_INSTALL_PREFIX="${PREFIX}"
    make -j"${CPU_COUNT}"
    make install
    mv "${PREFIX}/bin/raptor" "${PREFIX}/bin/raptor_${INSTRUCTION_SET}"
    cd ../..
done

cp "${RECIPE_DIR}/raptor" "${PREFIX}/bin/raptor"
chmod +x "${PREFIX}/bin/raptor"
