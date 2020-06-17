#!/bin/bash

# not sure whether needed (and will fail due to missing R-files):
mkdir -p $PREFIX/bin
cp run_app.sh $PREFIX/bin
chmod 0755 "${PREFIX}/bin/run_app.sh"


