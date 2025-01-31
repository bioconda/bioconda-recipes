#!/usr/bin/env bash

set -euxo pipefail

# cpan DBIx::Class
# cpan Data::Printer

# Make scripts executable
chmod -R a+x ./code/scripts/*.pl
export PERL5LIB="./code/modules"