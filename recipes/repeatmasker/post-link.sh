#!/bin/bash

if [[ -f /.dockerenv ]]; then
    cat >> "$PREFIX/.messages.txt" <<EOF
To install the databases needed by RepeatMasker, execute:

wget -O Dfam-RepeatMasker.lib.gz https://www.dfam.org/releases/Dfam_3.8/families/Dfam-RepeatMasker.lib.gz
gunzip -c Dfam-RepeatMasker.lib.gz > ${PREFIX}/share/RepeatMasker/Libraries/RepeatMasker.lib
rm -rf Dfam-RepeatMasker.lib.gz

EOF
else
    echo "Dfam-RepeatMasker.lib.gz from www.dfam.org"
    wget -O Dfam-RepeatMasker.lib.gz https://www.dfam.org/releases/Dfam_3.8/families/Dfam-RepeatMasker.lib.gz
    gunzip -c Dfam-RepeatMasker.lib.gz > ${PREFIX}/share/RepeatMasker/Libraries/RepeatMasker.lib
    rm -rf Dfam-RepeatMasker.lib.gz
fi
