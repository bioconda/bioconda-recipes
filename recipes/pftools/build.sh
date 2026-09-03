#!/bin/bash
set -x -e

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"

# programs intsalled
# pfscanV3 pfsearchV3 pfcalibrateV3 pfemit pfpam pfdump pfindex gtop htop ptoh ptof pfw 2ft 6ft psa2msa pfscale pfsearch pfscan pfmake
# ps_scan.pl scramble_fasta.pl sort_fasta.pl split_profile_file.pl make_iupac_cmp.pl fasta_to_fastq.pl compare_2_profiles.pl

if [[ `uname -s` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_C_COMPILER="${CC}" \
 -DCMAKE_C_FLAGS="${CFLAGS}" \
 -Wno-dev -Wno-deprecated --no-warn-unused-cli \
 "${CONFIG_ARGS}"
cmake --build build --target install -j "${CPU_COUNT}"

# the container environment prevents the tests from completing, when they otherwise would
#make test VERBOSE=1
