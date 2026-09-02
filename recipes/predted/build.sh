#!/bin/bash
set -ex

# 1) Install the Python package
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

# 2) Generate model.h from the shipped model file
xxd -i predted/model.txt > c_src/model.h
# Fix variable names to match what predTED.c expects
sed -i.bak 's/predted_model_txt/model_txt/g' c_src/model.h
rm -f c_src/model.h.bak

# 3) Build the CLI binary
mkdir -p "${PREFIX}/bin"
${CC} ${CFLAGS} -O2 -Wall -Ic_src \
    $(pkg-config --cflags-only-I LightGBM 2>/dev/null || true) \
    -fopenmp \
    -o "${PREFIX}/bin/predted" \
    c_src/predTED.c c_src/predted_features.c \
    $(pkg-config --libs LightGBM 2>/dev/null || echo "-lLightGBM") \
    -lm ${LDFLAGS}
