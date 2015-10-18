#!/bin/bash
set -eu -o pipefail

sed -i 's/^MANS=.*/MANS=/' Makefile
sed -i 's/install $(MANS)/# install $(MANS)/' Makefile
make PREFIX=$PREFIX
make install PREFIX=$PREFIX
