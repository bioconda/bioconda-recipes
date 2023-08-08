#!/bin/bash

set -o errexit -o pipefail

find="v5.0.7"
replace="5.0.7"

sed 's/$find/$replace/g' $SRC_DIR/META.json
sed 's/$find/$replace/g' $SRC_DIR/Build.PL
sed 's/$find/$replace/g' $SRC_DIR/lib/Minion/Backend/SQLite.pm


echo $find
echo $replace

perl Build.PL INSTALLDIRS=site \
    INC="-I${PREFIX}/include" LIBS="-L${PREFIX}/lib -lz"
sed 's/$find/$replace/g' $SRC_DIR/Build
perl ./Build
perl ./Build test
# Make sure this goes in site
perl ./Build install --installdirs site
