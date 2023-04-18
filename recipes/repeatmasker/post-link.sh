#!/bin/bash

wget -O Dfam_curatedonly.h5.gz https://www.dfam.org/releases/Dfam_3.7/families/Dfam_curatedonly.h5.gz

zcat Dfam_curatedonly.h5.gz > ${PREFIX}/share/RepeatMasker/Libraries/Dfam.h5
