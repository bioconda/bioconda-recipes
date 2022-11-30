#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

cp -r lib modules gsea.args logging.properties $PACKAGE_HOME 

echo -e """exec java --module-path="${PACKAGE_HOME}/modules" \${JVM_MEM_OPTS:-"-Xmx4g"} \
    -Djava.awt.headless=true \
    -Djava.util.logging.config.file="${PACKAGE_HOME}/logging.properties" \
    @"${PACKAGE_HOME}/gsea.args" \
    --patch-module="jide.common=${PACKAGE_HOME}/lib/jide-components-3.7.4.jar:${PACKAGE_HOME}/lib/jide-dock-3.7.4.jar:${PACKAGE_HOME}/lib/jide-grids-3.7.4.jar" \
    --module=org.gsea_msigdb.gsea/xapps.gsea.CLI "\$@"
""" > gsea-cli

echo -e """exec java -showversion --module-path="${PACKAGE_HOME}/modules" \${JVM_MEM_OPTS:-"-Xmx4g"} \
    @"${PACKAGE_HOME}/gsea.args" \
    --patch-module="jide.common=${PACKAGE_HOME}/lib/jide-components-3.7.4.jar:${PACKAGE_HOME}/lib/jide-dock-3.7.4.jar:${PACKAGE_HOME}/lib/jide-grids-3.7.4.jar" \
    -Djava.util.logging.config.file="${PACKAGE_HOME}/logging.properties" \
    -Dapple.laf.useScreenMenuBar=true \
    --module=org.gsea_msigdb.gsea/xapps.gsea.GSEA "\$@"
""" > gsea

cp gsea gsea-cli $PREFIX/bin
