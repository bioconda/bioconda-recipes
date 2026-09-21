#!/bin/bash
set -euxo pipefail

$PYTHON -m pip install . -vv --no-deps --no-build-isolation

# Build the bam2vcf accelerator here rather than leaving it to varseek.utils.native, which
# would otherwise try to compile it at runtime -- a conda environment ships neither a C++
# compiler nor htslib headers, so that path always falls back to the slower Python walk.
# native.program_path() checks PATH before its own build cache, so this binary just works.
# -O3 comes after CXXFLAGS so it overrides the -O2 conda puts there: this binary exists
# purely to be faster than the Python fallback.
${CXX} ${CXXFLAGS} ${CPPFLAGS} -std=c++17 -O3 \
    varseek/cpp/bam2vcf.cpp \
    ${LDFLAGS} -lhts -lz -lpthread -lm \
    -o "${PREFIX}/bin/bam2vcf"
