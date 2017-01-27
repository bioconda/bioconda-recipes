#!/bin/bash

## The build file is taken from the biobuilds conda recipe by Cheng H. Lee,
## slightly adjusted to fit the bioconda format (the reason for migrating
## it to bioconda is to be able to use it as a requirement for the
## r-rphylip recipe, and currently bioconda does not search biobuilds:(
# Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

# Additional flags suggested by the philip makefile
CFLAGS="${CFLAGS} -fomit-frame-pointer -DUNX"

BUILD_ARCH=$(uname -m)
BUILD_OS=$(uname -s)

if [ "$BUILD_ARCH" == "ppc64le" ]; then
    # Just in case; make the same assumptions about plain "char" declarations
    # on little-endian POWER8 as we do on x86_64.
    CFLAGS="${CFLAGS} -fsigned-char"
fi

# Build
cd src
sed -i.bak "s:@@prefix@@:${PREFIX}:" phylip.h
if [ "$BUILD_OS" == "Darwin" ]; then
    # Tweak a few things for building shared libraries on OS X.
    sed -i.bak 's/-Wl,-soname/-Wl,-install_name/g' Makefile.unx
    sed -i.bak 's/\.so/.dylib/g' Makefile.unx
fi
make -f Makefile.unx CFLAGS="$CFLAGS" install

# Install
cd ..
SHARE_DIR="${PREFIX}/share/${PKG_NAME}-$PKG_VERSION-$PKG_BUILDNUM"
for d in fonts java exe; do
    install -d "${SHARE_DIR}/${d}"
    install ${d}/* "${SHARE_DIR}/${d}"
done
pushd "${SHARE_DIR}/java"
rm -f *.unx
popd

# Generate wrapper scripts in ${PREFIX}/bin like the Debian package does
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cat > "${PREFIX}/bin/phylip" << EOF
#!/bin/bash

BINDIR="${SHARE_DIR}/exe"
if [ \$# -lt 1 ] ; then
    echo "Usage: \$0 <program>" >&2
    echo "Existing programs are:" >&2
    ls \${BINDIR} >&2
    exit 1
fi

WRAPPER=\$0
PROGRAM=\$1
shift

if [ -x "\${BINDIR}/\${PROGRAM}" ]; then
    exec "\${BINDIR}/\${PROGRAM}" \$*
else
    echo "Usage: \${PROGRAM} does not exist in Phylip" >&2
    echo "Existing programs are:" >&2
    ls \${BINDIR} >&2
    exit 1
fi
EOF

cat > "${PREFIX}/bin/drawgram" <<EOF
#!/bin/bash
export "PATH=${SHARE_DIR}/exe:\$PATH"

# TODO: replace this with conda JRE
command -v java 1>/dev/null 2>/dev/null ||
    { echo "FATAL: Cannot find 'java' executable" >&2; exit 1; }
java -cp "${SHARE_DIR}/java/DrawTree.jar" drawgram.DrawgramUserInterface
EOF

cat > "${PREFIX}/bin/drawtree" <<EOF
#!/bin/bash
export "PATH=${SHARE_DIR}/exe:\$PATH"

# TODO: replace this with conda JRE
command -v java 1>/dev/null 2>/dev/null ||
    { echo "FATAL: Cannot find 'java' executable" >&2; exit 1; }
java -cp "${SHARE_DIR}/java/DrawTree.jar" drawtree.DrawtreeUserInterface
EOF

cd "${PREFIX}/bin"
chmod 0755 phylip drawgram drawtree
