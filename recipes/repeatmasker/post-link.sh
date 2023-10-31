#!/bin/bash

echo "Downloading Dfam_curatedonly.h5.gz from www.dfam.org"
wget -O - https://www.dfam.org/releases/Dfam_3.7/families/Dfam_curatedonly.h5.gz | zcat > ${PREFIX}/share/RepeatMasker/Libraries/Dfam.h5
