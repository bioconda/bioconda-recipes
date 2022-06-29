#!/bin/bash

if [[ "$OSTYPE" != "darwin"* ]]; then

  make prefix="${PREFIX}" install

else
  declare -a BIN_LIST=(
    bowtie-build-s
    bowtie-build-l
    bowtie-align-s
    bowtie-align-l
    bowtie-inspect-s
    bowtie-inspect-l
  )

  declare -a PYTHON_WRAPPER_LIST=(
    bowtie-inspect
    bowtie-build
    bowtie
  )

  for file in "${BIN_LIST[@]}" "${PYTHON_WRAPPER_LIST[@]}"; do
    cp -f $file "${PREFIX}/bin/"
  done
fi

cp -r scripts "${PREFIX}/bin/"
