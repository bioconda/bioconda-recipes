#!/bin/bash

mkdir -p ${PREFIX}/lib/snostrip
mkdir -p ${PREFIX}/bin/snostrip
mkdir -p ${PREFIX}/share/snostrip

mv data ${PREFIX}/share/snostrip/.

cd bin/

./configure.sh ${PREFIX}

mv scripts ${PREFIX}/bin/snostrip/.
mv programs ${PREFIX}/bin/snostrip/.
mv packages ${PREFIX}/lib/snostrip/.
mv snoStrip.pl ${PREFIX}/bin/.
