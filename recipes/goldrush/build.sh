#!/bin/bash
set -eu -o pipefail


mkdir -p ${PREFIX}
meson --prefix ${PREFIX} build
cd build
ninja
ninja install

if [ `uname` == Darwin ]; then
    sed -i '' 's=/usr/bin/make=/usr/bin/env make=' ${PREFIX}/bin/goldrush
else
    sed -i '' 's=/usr/bin/make=/usr/bin/env make=' ${PREFIX}/bin/goldrush
fi
