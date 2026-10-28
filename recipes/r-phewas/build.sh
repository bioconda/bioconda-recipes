#!/bin/bash

export DISABLE_AUTOBREW=1

if [[ "$target_platform" =~ linux.* ]] || [[ "$target_platform" == "osx-64" ]] || [[ "$target_platform" == "osx-arm64" ]]; then
  mv DESCRIPTION DESCRIPTION.old
  grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
  ${R} CMD INSTALL --build . "${R_ARGS}"
else
  mkdir -p $PREFIX/lib/R/library/meta
  mv * $PREFIX/lib/R/library/meta
fi
