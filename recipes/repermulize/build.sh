#!/bin/bash
set -e

export DISABLE_AUTOBREW=1
export R_LIBS_USER="${PREFIX}/lib/R/library"
export R_LIBS="${PREFIX}/lib/R/library"

cd package/repermulize

grep -E '^Package:' DESCRIPTION

${R} CMD INSTALL --library="${PREFIX}/lib/R/library" . "${R_ARGS}"
