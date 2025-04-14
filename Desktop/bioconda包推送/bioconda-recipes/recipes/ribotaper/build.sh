#!/bin/bash

./configure --prefix=$PREFIX
make
make install
for f in create_annotations_files.bash create_metaplots.bash Ribotaper_ORF_find.sh Ribotaper.sh ; do
    sed -i.bak "s#/usr/bin/bash#/bin/bash#g" $PREFIX/bin/$f
done
rm -f $PREFIX/bin/*.bak
for f in $PREFIX/libexec/*.bash; do
    sed -i.bak "s#/usr/bin/bash#/bin/bash#g" $f
done
rm -f $PREFIX/libexec/*.bak
