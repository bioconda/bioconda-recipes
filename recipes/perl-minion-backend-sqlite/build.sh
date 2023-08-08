#!/bin/bash

set -o errexit -o pipefail

sed 's/v{{ version }}/{{ version }}/g' lib/Minion/Backend/SQLite.pm
sed 's/v{{ version }}/{{ version }}/g' *

perl Build.PL INSTALLDIRS=site \
    INC="-I${PREFIX}/include" LIBS="-L${PREFIX}/lib -lz"
perl ./Build
perl ./Build test
perl ./Build install --installdirs site
