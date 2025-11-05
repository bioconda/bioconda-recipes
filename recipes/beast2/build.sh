#!/bin/bash
pushd BeastFX
ant -lib ${BUILD_PREFIX}/lib/javafx-sdk*/lib linux
popd

TGT="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
mkdir -p ${PREFIX}/bin ${TGT}/lib ${TGT}/bin

for file in applauncher beast beauti densitree loganalyser logcombiner packagemanager treeannotator
    do envsubst '${PREFIX}:${PKG_NAME}:${PKG_VERSION}:${PKG_BUILDNUM}' < beast2/release/Linux/beast/bin/$file > ${TGT}/bin/$file
    chmod +x ${TGT}/bin/$file
    ln -s ${TGT}/bin/$file ${PREFIX}/bin
done

cp -R beast2/release/Linux/beast/lib/ ${TGT}
cp -R beast2/release/Linux/beast/{examples,images,fxtemplates} ${TGT}
cp -R BeastFX/locallib/*.jar ${TGT}
beast -version
exit 1
