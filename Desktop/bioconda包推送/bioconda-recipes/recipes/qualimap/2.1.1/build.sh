#!/bin/bash

TGT_BASE=share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
TGT="$PREFIX/$TGT_BASE"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
# Do not install Linux specific x86-acceleration libraries
if [ "$(uname)" == "Darwin" ]; then
    rm -f libIntel*.so
fi
# Set QUALIMAP_HOME to libraries path. This can help qualimap know where scripts/ forlder is.
sed -i.bak "/-classpath [^ ]*/i\export QUALIMAP_HOME='/opt/anaconda1anaconda2anaconda3/${TGT_BASE}'" qualimap
# Set classpath to libraries
sed -i.bak "s#-classpath [^ ]*#-classpath '/opt/anaconda1anaconda2anaconda3/${TGT_BASE}/*'#" qualimap
# MaxPermSize not supported with Java 8 -- avoid warnings
sed -i.bak "s/ -XX:MaxPermSize=1024m//" qualimap

cp qualimap $PREFIX/bin
chmod 0755 "${PREFIX}/bin/qualimap"
cp -rvp scripts $TGT
cp -rvp species $TGT
cp -rvp lib/*.jar $TGT
cp *.jar $TGT
