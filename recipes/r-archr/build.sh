#!/bin/bash
export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build --install-tests . ${R_ARGS}
