#!/bin/bash

export CC="\"${CC} -fcommon\""
## Install hts-nim dependency
pushd hts-nim
nimble install -y
popd

## Install CONDUIT proper
nimble build -y --verbose
chmod +x conduit
chmod +x conduitUtils
# chmod +x conduit_clustering
mkdir -p "${PREFIX}/bin"
cp conduit "${PREFIX}/bin/conduit"
cp conduitUtils "${PREFIX}/bin/conduitUtils"
# cp conduit_clustering "${PREFIX}/bin/conduit_clustering"
