#!/usr/bin/env bash

TARGET="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
BIN=${PREFIX}/bin
[ -d "$TARGET" ] || mkdir -p "$TARGET"
[ -d "$BIN" ] || mkdir -p "$BIN"

cd "${SRC_DIR}"
mv lsd-$PKG_VERSION.jar ${TARGET}

# Generate the lsd script used to invoke the java program
cat << EOF > ${TARGET}/lsd
#/usr/bin/env bash
java -jar -Xmx2G ${TARGET}/lsd-${PKG_VERSION}.jar \$@
EOF

# Create a link to the startup script.
ln -s ${TARGET}/lsd ${BIN}/lsd
chmod 0755 ${BIN}/lsd

