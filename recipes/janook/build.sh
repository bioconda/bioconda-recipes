#!/bin/bash
set -euo pipefail

mkdir -p "$PREFIX/share/janook" "$PREFIX/bin"
cp -r janook-cli-*.jar lib LICENSE NOTICE "$PREFIX/share/janook/"

jar=$(basename janook-cli-*.jar)
cat > "$PREFIX/bin/janook" <<WRAPPER
#!/bin/bash
exec java -jar "$PREFIX/share/janook/$jar" "\$@"
WRAPPER
chmod +x "$PREFIX/bin/janook"
