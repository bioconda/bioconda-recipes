#!/bin/bash

set -eu -o pipefail

sed -i.bak "s#g++#${CXX}#" Makefile
# Maven compiler defaults in upstream pom.xml target Java 6, which fails with modern JDKs.
if [ -f pom.xml ]; then
  sed -i.bak -E \
    -e 's#<source>1\\.6</source>#<source>1.8</source>#g' \
    -e 's#<target>1\\.6</target>#<target>1.8</target>#g' \
    -e 's#<source>6</source>#<source>8</source>#g' \
    -e 's#<target>6</target>#<target>8</target>#g' \
    pom.xml
fi
make
outdir="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
mkdir -p "${outdir}"
mkdir -p "${PREFIX}/bin"

cp target/abra2-${PKG_VERSION}-jar-with-dependencies.jar "${outdir}/abra2.jar"
cp "${RECIPE_DIR}/abra2-wrapper.sh" "${outdir}/abra2"
chmod +x "${outdir}/abra2"
ln -s "${outdir}/abra2" "${PREFIX}/bin/abra2"
