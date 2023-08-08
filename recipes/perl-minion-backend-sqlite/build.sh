#!/bin/bash

set -o errexit -o pipefail

find="v{{ version }}"
replace="{{ version }}"

sed 's/$find/$replace/g' $BUILD_PREFIX/META.json
sed 's/$find/$replace/g' $BUILD_PREFIX/Build.PL
sed 's/$find/$replace/g' $BUILD_PREFIX/lib/Minion/Backend/SQLite.pm


echo $find
echo $replace

perl Build.PL INSTALLDIRS=site \
    INC="-I${PREFIX}/include" LIBS="-L${PREFIX}/lib -lz"
sed 's/$find/$replace/g' $BUILD_PREFIX/Build
perl ./Build
perl ./Build test
# Make sure this goes in site
perl ./Build install --installdirs site
