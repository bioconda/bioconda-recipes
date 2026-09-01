#!/bin/bash
make CC="$CC"
mkdir -p ${PREFIX}/bin
cp epics epocs epocs_mcmc evoscope ${PREFIX}/bin
cp -r Scripts/ ${PREFIX}/bin
