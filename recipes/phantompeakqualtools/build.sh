#!/bin/bash

mkdir -p ${PREFIX}/bin

#add shebang to make directly executable
cat <(
      echo '#!/usr/bin/env Rscript'
    ) run_spp.R \
> $PREFIX/bin/run_spp.R

chmod +x $PREFIX/bin/run_spp.R

