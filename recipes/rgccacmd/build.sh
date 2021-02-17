#!/bin/bash
cp -r ${SRC_DIR}/R ${SRC_DIR}/inst ${PREFIX}
if [[ $target_platform =~ linux.* ]] || [[ $target_platform == win-32 ]]; then
  $R CMD INSTALL --build .
else
  mkdir -p $PREFIX/lib/R/library/rgcca
  mv * $PREFIX/lib/R/library/rgcca
fi