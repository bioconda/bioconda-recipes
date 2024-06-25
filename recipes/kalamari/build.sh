#!/bin/bash

mkdir -pv $PREFIX/bin
mkdir -pv $PREFIX/src
mkdir -pv $PREFIX/share/${PKG_NAME}-${PKG_VERSION}

# Add in the correct version for the build
sed -i.bak "s/VERSION=.\+/VERSION=\"${PKG_VERSION}\"/" bin/downloadKalamari.sh

for i in bin/*.pl bin/*.sh bin/*.py; do
  chmod -v 755 $i
  cp -vf $i $PREFIX/bin/
done

for i in src/*.tsv; do 
  cp -vf $i $PREFIX/src/
done
cp -rvf src/taxonomy $PREFIX/src/
