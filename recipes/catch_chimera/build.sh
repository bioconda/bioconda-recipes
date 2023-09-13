#! /bin/bash

#link in /bin, following bioconda rules
mkdir -p "${PREFIX}/bin"
cp "$SRC_DIR/CATCh_v1.run" "${PREFIX}/bin"

