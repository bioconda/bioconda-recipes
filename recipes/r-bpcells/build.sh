#!/bin/bash
export DISABLE_AUTOBREW=1
pushd r/
${R} CMD INSTALL --build --install-tests . ${R_ARGS}
popd
