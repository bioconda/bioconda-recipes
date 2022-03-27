#!/bin/sh
set -x -e

# programs intsalled
# pfscanV3 pfsearchV3 pfcalibrateV3 pfemit pfpam pfdump pfindex gtop htop ptoh ptof pfw 2ft 6ft psa2msa pfscale pfsearch pfscan pfmake
# ps_scan.pl scramble_fasta.pl sort_fasta.pl split_profile_file.pl make_iupac_cmp.pl fasta_to_fastq.pl compare_2_profiles.pl
 
mkdir build
cd build/
cmake -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" ..
make CC=${CC} CXX=${CXX} F77=${GFORTRAN} CFLAGS="$CFLAGS $LDFLAGS"
make install
make test VERBOSE=1 || cat Testing/Temporary/LastTest.log
exit 1
