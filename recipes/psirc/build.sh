#!/usr/bin/env bash
set -euo pipefail

# Legacy kallisto code relies on transitive <limits> includes absent in new GCC.
export CXXFLAGS="${CXXFLAGS} -include limits"

mkdir -p "${PREFIX}/bin" "${PREFIX}/lib/perl5/site_perl"
for script in psirc_v1.0.pl create_custom_transcriptome_fa.pl; do
    sed '1s|^#!.*|#!/usr/bin/env perl|' "${script}" > "${PREFIX}/bin/${script}"
    chmod 755 "${PREFIX}/bin/${script}"
done
ln -s psirc_v1.0.pl "${PREFIX}/bin/psirc"

# Build the required fork natively; the bundled executables are x86-64 only.
# Its CMake files discover zlib but omit it from the link libraries.
cmake -S kallisto-b -B kallisto-b/build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD_LIBRARIES="-lz" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"
cmake --build kallisto-b/build --target kallisto --parallel "${CPU_COUNT}"
install -m 755 kallisto-b/build/src/kallisto "${PREFIX}/bin/kallisto_b"

install -m 644 scripts/FAlite.pm "${PREFIX}/lib/perl5/site_perl/FAlite.pm"

cmake -S psirc-quant -B psirc-quant/release \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"
cmake --build psirc-quant/release --parallel "${CPU_COUNT}"
cmake --install psirc-quant/release
