#!/bin/bash

if [[ $target_platform =~ linux.* ]] || [[ $target_platform == osx-64 ]]; then
  export DISABLE_AUTOBREW=1
  mv DESCRIPTION DESCRIPTION.old
  grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
  $R CMD INSTALL --build .
else
  mkdir -p $PREFIX/lib/R/library/BisqueRNA
  mv * $PREFIX/lib/R/library/BisqueRNA
fi
