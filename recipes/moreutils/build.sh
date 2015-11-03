#!/bin/bash
set -eu -o pipefail

# Skip man files due to dependencies
sed -i 's/^MANS=.*/MANS=/' Makefile
sed -i 's/install $(MANS)/# install $(MANS)/' Makefile
# avoid installing parallel since it conflicts with GNU parallel
sed -i 's/parallel//' Makefile
make PREFIX=$PREFIX
make install PREFIX=$PREFIX
