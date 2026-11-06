#!/bin/bash

set -eux -o pipefail

cd Source_Code

# Upstream's Linux compile line (README, section 4A). libqsopt.linux.a is a
# prebuilt non-PIC archive, so the link needs -no-pie, as the README notes.
${CC} ${CFLAGS} ${CPPFLAGS} -O3 -fopenmp \
  -o ldak ldak_nomkl.c libqsopt.linux.a \
  ${LDFLAGS} -no-pie \
  -llapack -lblas -lm -lz -lzstd

install -d "${PREFIX}/bin"
install -m 0755 ldak "${PREFIX}/bin/ldak"
