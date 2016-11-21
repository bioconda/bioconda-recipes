#!/bin/bash

TARGET="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TARGET" ] || mkdir -p "$TARGET"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv lsd-$PKG_VERSION.jar ${TARGET}

# Generate the lsd script used to invoke the java program
cat << EOF > ${PREFIX}/bin/lsd
#/bin/bash
java -jar -Xmx2G ${TARGET}/lsd-${PKG_VERSION}.jar \$@
EOF

# Make it executable.
chmod a+x ${PREFIX}/bin/lsd

