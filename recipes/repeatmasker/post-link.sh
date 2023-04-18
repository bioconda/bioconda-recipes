#!/bin/bash

echo "Downloading Dfam_curatedonly.h5.gz from www.dfam.org"
wget -O Dfam_curatedonly.h5.gz https://www.dfam.org/releases/Dfam_3.7/families/Dfam_curatedonly.h5.gz

zcat Dfam_curatedonly.h5.gz > ${PREFIX}/share/RepeatMasker/Libraries/Dfam.h5
rm Dfam_curatedonly.h5.gz
