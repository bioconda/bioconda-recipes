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

# Find original directory of bash script, resovling symlinks
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128
SOURCE="\${BASH_SOURCE[0]}"
while [ -h "\$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="\$( cd -P "\$( dirname "\$SOURCE" )" && pwd )"
    SOURCE="\$(readlink "\$SOURCE")"
    [[ \$SOURCE != /* ]] && SOURCE="\$DIR/\$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="\$( cd -P "\$( dirname "\$SOURCE" )" && pwd )"

JAR=\${DIR}/lsd-${PKG_VERSION}.jar
HEAP_SIZE=-Xmx4G

java -jar \${HEAP_SIZE} \${JAR} \$@
EOF

# Create a link to the startup script.
ln -s ${TARGET}/lsd ${BIN}/lsd
chmod 0755 ${BIN}/lsd

