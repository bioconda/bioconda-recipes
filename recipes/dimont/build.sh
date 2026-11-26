#!/usr/bin/env bash
set -euo pipefail

SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
mkdir -p "${SHARE_DIR}/lib" "${PREFIX}/bin" build/classes

# Same classpath as upstream build.xml (property "cp"). Do NOT use
# `find lib -name '*.jar'`: lib/xml-commons/batik.jar breaks javac/java with
# URI parsing errors in conda-build paths.
LIBS="BigWig.jar
junit-4.5.jar
htsjdk-2.5.0-4-gd683012-SNAPSHOT.jar
numericalMethods.jar
RClient-0.6.7.jar
biojava-live.jar
bytecode-1.9.0.jar
core-1.9.0.jar
xml-commons/pdf-transcoder.jar
xml-commons/xmlgraphics-commons-1.5.jar
Jama-1.0.3.jar
xml-commons/batik-transcoder.jar
xml-commons/batik-dom.jar
xml-commons/batik-svggen.jar
xml-commons/batik-svg-dom.jar
xml-commons/batik-awt-util.jar
xml-commons/batik-util.jar
ssj/colt-1.2.0.jar
ssj/ssj-3.3.1.jar"

CP=""
for jar in ${LIBS}; do
    CP="${CP:+${CP}:}lib/${jar}"
done

# Entry points shipped by the authors (Dimont.jar, SlimDimont.jar,
# DimontPredictor, SlimDimontPredictor, DimontGenomeScan) plus the
# multi-tool command line interface DimontCLI.
javac \
    -encoding UTF-8 \
    -source 8 \
    -target 8 \
    -nowarn \
    -cp "${CP}" \
    -sourcepath "." \
    -d build/classes \
    projects/dimont/Dimont.java \
    projects/dimont/DimontPredictor.java \
    projects/dimont/DimontGenomeScan.java \
    projects/dimont/DimontCLI.java \
    projects/slim/SlimDimont.java \
    projects/slim/SlimDimontPredictor.java

# Resources (e.g. projects/*/help*.txt) are read via getResourceAsStream.
find de projects -type f \
    ! -name '*.java' ! -name '*.jardesc.xml' ! -name '*.html' \
    ! -name '*.so' ! -name '*.dll' ! -name '*.jnilib' ! -name '*.c' ! -name '*.h' \
    -exec cp --parents {} build/classes/ \;

jar cf "${SHARE_DIR}/dimont.jar" -C build/classes .

for jar in ${LIBS}; do
    mkdir -p "${SHARE_DIR}/lib/$(dirname "${jar}")"
    cp "lib/${jar}" "${SHARE_DIR}/lib/${jar}"
done

# <command>:<main class>. Arguments are passed on unchanged, so the command
# line is the one documented by the authors (key=value pairs).
for entry in \
    dimont:projects.dimont.Dimont \
    slimdimont:projects.slim.SlimDimont \
    dimont-predictor:projects.dimont.DimontPredictor \
    slimdimont-predictor:projects.slim.SlimDimontPredictor \
    dimont-genomescan:projects.dimont.DimontGenomeScan \
    dimont-cli:projects.dimont.DimontCLI
do
    cmd="${entry%%:*}"
    main="${entry#*:}"
    sed \
        -e "s|@SHARE_NAME@|${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}|" \
        -e "s|@MAIN_CLASS@|${main}|" \
        -e "s|@LIBS@|${LIBS//$'\n'/ }|" \
        "${RECIPE_DIR}/launcher.sh" > "${PREFIX}/bin/${cmd}"
    chmod +x "${PREFIX}/bin/${cmd}"
done
