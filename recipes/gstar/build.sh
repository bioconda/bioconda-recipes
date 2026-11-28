#!/bin/bash
set -euo pipefail

# portable shebang; "-w" moved to "use warnings" (env cannot pass arguments)
sed -i.bak -e '1s|^#!.*|#!/usr/bin/env perl|' -e '1a use warnings;' GSTAr.pl
mkdir -p "${PREFIX}/bin"
install -m 0755 GSTAr.pl "${PREFIX}/bin/GSTAr.pl"
