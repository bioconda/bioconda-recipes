#!/bin/bash
set -euxo pipefail

# Gedi's pom.xml writes build outputs to ${user.dir} (the current working
# directory), not to a fixed target/ inside the module. Mirror the layout
# documented in the upstream README: create a sibling "bin" directory and
# invoke maven against the Gedi module from inside it.
mkdir -p build_out
cd build_out
mvn -f "${SRC_DIR}/Gedi/pom.xml" package -DskipTests=true -B \
    -Dproject.build.sourceEncoding=UTF-8 \
    -Dfile.encoding=UTF-8

# The above produces in build_out/:
#   Gedi-${version}.jar
#   gedi.jar               (copy of the versioned jar)
#   lib/*.jar              (runtime classpath)
#   gedi                   (upstream wrapper script)
#   bamlist2cit            (upstream wrapper script)

TGT="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
mkdir -p "${TGT}"
mkdir -p "${PREFIX}/bin"

# Install the jar(s) and runtime classpath.
cp -p Gedi-${PKG_VERSION}.jar "${TGT}/"
cp -p gedi.jar "${TGT}/"
cp -rp lib "${TGT}/"

# Install our own wrapper (POSIX-portable, uses conda-installed java, no
# upstream-specific hostname or --add-opens dependence on a specific JDK).
install -m 0755 "${RECIPE_DIR}/gedi.sh" "${TGT}/gedi"
install -m 0755 "${RECIPE_DIR}/bamlist2cit.sh" "${TGT}/bamlist2cit"

# Expose the wrappers on PATH.
ln -s "${TGT}/gedi" "${PREFIX}/bin/gedi"
ln -s "${TGT}/bamlist2cit" "${PREFIX}/bin/bamlist2cit"
