#!/bin/bash

mkdir -p $PREFIX/bin

echo -e '#!/usr/bin/env python3\n' > utils/dnascent2bedgraph.tmp 
cat utils/dnascent2bedgraph.py >> utils/dnascent2bedgraph.tmp 
mv utils/dnascent2bedgraph.tmp utils/dnascent2bedgraph.py
chmod a+x utils/dnascent2bedgraph.py
cp utils/dnascent2bedgraph.py $PREFIX/bin

make

cp bin/DNAscent $PREFIX/bin
