#!/bin/bash

TGT_BASE=share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
TGT="$PREFIX/$TGT_BASE"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"

# Minimum required for operation
cp RTG.jar $TGT
cp rtg $TGT
# Optional utility scripts (e.g. bash completion)
cp -rvp scripts $TGT

echo "RTG_TALKBACK=true     # Attempt to send crash logs to realtime genomics, true to enable
RTG_USAGE=false   # Enable simple usage logging, true to enable
RTG_JAVA_OPTS=    # Additional arguments passed to the JVM
if [[ ! -z \"\${JAVA_HOME}\" ]]; then
    RTG_JAVA=\${JAVA_HOME}/bin/java   # point to the installed Java
else
    RTG_JAVA=/opt/anaconda1anaconda2anaconda3/bin/java   # default old-style where anaconda installed Java
fi
RTG_JAR=/opt/anaconda1anaconda2anaconda3/${TGT_BASE}/RTG.jar" > $TGT/rtg.cfg

ln -s $TGT/rtg $PREFIX/bin
chmod 0755 "${PREFIX}/bin/rtg"
