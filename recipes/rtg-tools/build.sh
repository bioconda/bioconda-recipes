#!/bin/bash

TGT_BASE=share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
TGT="$PREFIX/$TGT_BASE"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
# Do not install Linux specific x86-acceleration libraries
cp -rvp third-party $TGT
cp RTG.jar $TGT
cp rtg $TGT

echo "RTG_TALKBACK=     # Attempt to send crash logs to realtime genomics, true to enable
RTG_USAGE=        # Enable simple usage logging, true to enable
RTG_JAVA_OPTS=    # Additional arguments passed to the JVM
RTG_JAR=/opt/anaconda1anaconda2anaconda3/${TGT_BASE}/RTG.jar" > $TGT/rtg.cfg

ln -s $TGT/rtg $PREFIX/bin
chmod 0755 "${PREFIX}/bin/rtg"
