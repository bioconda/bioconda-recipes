#!/bin/bash

export LC_ALL="en_US.UTF-8"
export DISABLE_AUTOBREW=1

mv DESCRIPTION DESCRIPTION.old
grep -va '^Priority: ' DESCRIPTION.old > DESCRIPTION

${R} CMD INSTALL --build . "${R_ARGS}"
