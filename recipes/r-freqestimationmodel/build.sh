#!/bin/bash
export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build . --no-build-vignettes ${R_ARGS}
