#!/bin/bash
ant linux

mkdir -p ${PREFIX}/bin ${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/lib

for file in applauncher beast beauti densitree loganalyser logcombiner packagemanager treeannotator
    do envsubst '${PREFIX}:${PKG_NAME}:${PKG_VERSION}:${PKG_BUILDNUM}' < release/Linux/beast/bin/$file > ${PREFIX}/bin/$file
    chmod +x ${PREFIX}/bin/$file
done

cp -R release/Linux/beast/lib/ ${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
cp -R release/Linux/beast/{examples,images,templates} ${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
