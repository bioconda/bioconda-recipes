#!/bin/bash
set -eu -o pipefail

outdir="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$outdir"
mkdir -p "$PREFIX/bin"

# 1. Install CLI wrapper
cp fastreeR.py "$outdir/"
cat <<EOF > "$PREFIX/bin/fastreeR"
#!/bin/bash
export FASTREER_JAR_DIR="$outdir"
exec python3 "$outdir/fastreeR.py" "\$@"
EOF
chmod 0755 "$PREFIX/bin/fastreeR"

# 2. Install Java backend
cp inst/java/*.jar "$outdir"

# 3. Install LICENSE
cp LICENSE.md "$outdir"
