#!/bin/bash

##https://github.com/bioconda/bioconda-recipes/blob/4a90b4a7dedfdaeb04f967573fc676fdf53caee7/recipes/papaa/build.sh

mkdir -p "${PREFIX}/bin"
mkdir -p ${PREFIX}/share/epigen
cp -r * ${PREFIX}/share/epigen
cp -r corpora ${PREFIX}/share/epigen
cp -r ext ${PREFIX}/share/epigen

ln -s ${PREFIX}/share/epigen/*.py ${PREFIX}/bin/
ln -s ${PREFIX}/share/epigen/utils/* ${PREFIX}/bin/

chmod +x ${PREFIX}/share/epigen/*.py
chmod +x ${PREFIX}/share/epigen/utils/*



