#!/bin/bash
mv bin ${PREFIX}/
mv lib/* ${PREFIX}/lib/
ls -l ${PREFIX}/lib/
${PREFIX}/bin/dorado basecaller --help
