#!/bin/bash

set -o errexit -o pipefail

perl Build.PL INSTALLDIRS=site \
    INC="-I${PREFIX}/include" LIBS="-L${PREFIX}/lib -lz"
perl ./Build
perl ./Build test
perl ./Build install --installdirs site
