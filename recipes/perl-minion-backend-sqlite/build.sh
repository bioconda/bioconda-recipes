#!/bin/bash

set -o errexit -o pipefail


sed -i 's/v5.0.7/5.0.7/g' $SRC_DIR/META.json
sed -i 's/v5.0.7/5.0.7/g' $SRC_DIR/Build.PL
sed -i 's/v5.0.7/5.0.7/g' $SRC_DIR/lib/Minion/Backend/SQLite.pm


perl Build.PL INSTALLDIRS=site \
    INC="-I${PREFIX}/include" LIBS="-L${PREFIX}/lib -lz"
sed -i 's/v5.0.7/5.0.7/g' $SRC_DIR/Build
perl ./Build
perl ./Build test
# Make sure this goes in site
perl ./Build install --installdirs site
