#!/bin/bash

export DISABLE_AUTOBREW=1
export LC_ALL="en_US.UTF-8"

# shellcheck disable=SC2086
${R} CMD INSTALL --build . "${R_ARGS}"
