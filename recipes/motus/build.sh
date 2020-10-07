#!/bin/bash

# This package doesn't follow POSIX folder nomenclature
# The package also includes a bin/ folder which is in fact used as a repository
# for other python scripts that are imported by the main 'motus' script
# The 'motus' script searches for ./bin and ./db_mOTU relative to its location

# For these reasons data is bundled to a custom directory and a tiny wrapper
# is added below that simply calls motus in the custom location

share=share/motus-${PKG_VERSION}/
pkgdir=$PREFIX/$share

mkdir -p "$pkgdir"
# custom python scripts from the tool
cp -pr bin "$pkgdir"
# main script
cp -pr motus "$pkgdir"
cp -pr LICENSE* "$pkgdir"

# accessory files (setup.py and test.py) to download the tool's database db_mOTU
# and test.py that checks if all dependencies are in order and the tool runs as expected
# These are called in post-link.sh
cp -pr ./*.py "$pkgdir"

cat > "$PREFIX/bin/motus" <<EOF
#!/usr/bin/env bash
BINDIR="\$(cd "\$(dirname "\${0}")" && pwd -P)"
exec python \$BINDIR/../$share/motus "\$@"
EOF

chmod +x "$PREFIX/bin/motus"
