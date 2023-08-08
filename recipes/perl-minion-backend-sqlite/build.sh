#!/bin/bash

set -o errexit -o pipefail

find="v{{ version }}"
replace="{{ version }}"

sed 's/$find/$replace/g' $BUILD_PREFIX/*
sed 's/$find/$replace/g' $BUILD_PREFIX/lib/Minion/Backend/SQLite.pm

perl Build.PL INSTALLDIRS=site \
    INC="-I${PREFIX}/include" LIBS="-L${PREFIX}/lib -lz"
sed 's/$find/$replace/g' $BUILD_PREFIX/*
perl ./Build
perl ./Build test
perl ./Build install --installdirs site
