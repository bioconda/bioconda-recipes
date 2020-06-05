#!/bin/bash

set -eu -o pipefail

mkdir -p ${PREFIX}/bin

cd src
make -j 4 CC=$CC

cp baseml ${PREFIX}/bin/
cp basemlg ${PREFIX}/bin/
cp chi2 ${PREFIX}/bin/
cp codeml ${PREFIX}/bin/
cp evolver ${PREFIX}/bin/
cp infinitesites ${PREFIX}/bin/
cp mcmctree ${PREFIX}/bin/
cp pamp ${PREFIX}/bin/
cp yn00 ${PREFIX}/bin/

cd ..
cp -r dat ${PREFIX}/
