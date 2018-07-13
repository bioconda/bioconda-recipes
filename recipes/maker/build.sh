#!/bin/bash

cd src/

# enable mpi
echo "yes" | perl Build.PL

perl ./Build install

cd ..

# Maker needs to check RepeatMasker's libraries content which are not in the expected location
sed -i.bak 's|Libraries/RepeatMaskerLib.embl|../share/RepeatMasker/Libraries/RepeatMaskerLib.embl|g' lib/GI.pm

mv bin/* $PREFIX/bin
mkdir -p $PREFIX/perl/lib/
mv perl/lib/* $PREFIX/perl/lib/
mv lib/* $PREFIX/lib/
