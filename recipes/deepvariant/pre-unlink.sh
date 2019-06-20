#!/bin/bash
set -eu -o pipefail
OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/models
rm -rf OUTDIR
