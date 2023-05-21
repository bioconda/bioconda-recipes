#!/bin/bash

DESTDIR="${PREFIX}/lib/barrnap"
mkdir -p "${DESTDIR}"
mkdir -p ${PREFIX}/bin

# copy selectively, we only need the perl script
# in the bin folder and the db folder containing the
# hmms.
# we don't need
# - the nhmmer binaries (provided through hmmer package)
# - the big examples / test cases
# - the build folder containing training data and scripts
cp -av LICENSE* README* bin db "${DESTDIR}/"

# copy one example for testing
#mkdir -p "${DESTDIR}/examples"
#cp -av examples/small.fna "${DESTDIR}/examples"

# link the primary perl script
ln -s "${DESTDIR}/bin/barrnap" "${PREFIX}/bin/barrnap"
