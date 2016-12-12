#!/bin/bash

mkdir -vp ${PREFIX}/bin;
mkdir -vp ${PREFIX}/share/${PKG_NAME}-${PKG_VERSION};

mv -v $SRC_DIR/bin/sbt-launch.jar ${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/;

cat > ${PREFIX}/bin/sbt <<EOF
#!/bin/bash

SBT_REL_DIR="\$(dirname \${0})"
SBT_LAUNCHER="\${SBT_REL_DIR}/../share/${PKG_NAME}-${PKG_VERSION}/sbt-launch.jar"
SBT_REPO_DIR="\${SBT_REL_DIR}/../share/${PKG_NAME}-${PKG_VERSION}/repo"
JVM_OPTS="-Dfile.encoding=UTF-8 -Xss8M -Xmx2G -XX:ReservedCodeCacheSize=64M -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -Dsbt.ivy.home=\${SBT_REPO_DIR}"

exec java \${JVM_OPTS} -jar \${SBT_LAUNCHER} \${@}

EOF

chmod -v 755 ${PREFIX}/bin/sbt;
