#!/bin/bash

set -euo pipefail

perl Makefile.PL INSTALLDIRS=site
make
make test
make install
