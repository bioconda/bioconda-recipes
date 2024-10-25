#!/bin/bash
export DISABLE_AUTOBREW=1
if [ ! -f DESCRIPTION ]; then
    echo "Error: DESCRIPTION file not found"
    exit 1
fi
mv DESCRIPTION DESCRIPTION.old || exit 1
grep -va '^Priority: ' DESCRIPTION.old > DESCRIPTION || exit 1
${R} CMD INSTALL --build . ${R_ARGS}
