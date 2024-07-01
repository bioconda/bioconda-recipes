#!/bin/bash

if [ -f /.dockerenv ]; then
    cat >> "$PREFIX/.messages.txt" <<EOF
To install the databases needed by RepeatMasker, execute:

wget -O - dfam38_full.0.h5.gz https://dfam.org/releases/Dfam_3.8/families/FamDB/dfam38_full.0.h5.gz | zcat > ${PREFIX}/share/RepeatMasker/Libraries/famdb/dfam38_full.0.h5
rm -f dfam38_full.0.h5.gz

EOF
else
    echo "Downloading dfam38_full.0.h5.gz from www.dfam.org"
    wget -O - dfam38_full.0.h5.gz https://dfam.org/releases/Dfam_3.8/families/FamDB/dfam38_full.0.h5.gz | zcat > ${PREFIX}/share/RepeatMasker/Libraries/famdb/dfam38_full.0.h5
    rm -f dfam38_full.0.h5.gz
fi
