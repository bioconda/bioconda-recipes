#!/bin/bash

set -eu -o pipefail

cp -r dat ${PREFIX}/

cd src
make

cp baseml ${PREFIX}/bin
cp basemlg ${PREFIX}/bin
cp chi2 ${PREFIX}/bin
cp codeml ${PREFIX}/bin
cp evolver ${PREFIX}/bin
cp infinitesites ${PREFIX}/bin
cp mcmctree ${PREFIX}/bin
cp pamp ${PREFIX}/bin
cp yn00 ${PREFIX}/bin
