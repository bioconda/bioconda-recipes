#!/bin/bash

if [ -f /.dockerenv ]; then
    cat >> "$PREFIX/.messages.txt" <<EOF
To install the databases needed by RepeatMasker, execute:

wget -O Dfam_curatedonly.h5.gz https://www.dfam.org/releases/Dfam_3.7/families/Dfam_curatedonly.h5.gz
gunzip -c Dfam_curatedonly.h5.gz > ${PREFIX}/share/RepeatMasker/Libraries/Dfam.h5
rm Dfam_curatedonly.h5.gz

EOF
else
    echo "Downloading Dfam_curatedonly.h5.gz from www.dfam.org"
    wget -O Dfam_curatedonly.h5.gz https://www.dfam.org/releases/Dfam_3.7/families/Dfam_curatedonly.h5.gz
    gunzip -c Dfam_curatedonly.h5.gz > ${PREFIX}/share/RepeatMasker/Libraries/Dfam.h5
    rm Dfam_curatedonly.h5.gz
fi
