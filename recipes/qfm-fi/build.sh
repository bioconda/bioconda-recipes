#!/bin/bash
set -euxo pipefail

# The jars keep their layout: the manifest of QFM-FI.jar loads QFM-FI_lib/main.jar.
share="${PREFIX}/share/${PKG_NAME}"
mkdir -p "${share}/QFM-FI_lib" "${PREFIX}/bin"
install -m 644 QFM-FI.jar "${share}/QFM-FI.jar"
install -m 644 QFM-FI_lib/main.jar "${share}/QFM-FI_lib/main.jar"

# Wrapper script. Arguments starting with -X, -D or -XX: are passed to java.
cat > "${PREFIX}/bin/QFM-FI" <<EOF
#!/usr/bin/env bash
set -eu -o pipefail
jar="${share}/QFM-FI.jar"
java_cmd=java
if [ -x "${PREFIX}/bin/java" ]; then
    java_cmd="${PREFIX}/bin/java"
fi
java_opts=()
args=()
for arg in "\$@"; do
    case "\$arg" in
        -X*|-D*) java_opts+=("\$arg") ;;
        *)       args+=("\$arg") ;;
    esac
done
exec "\$java_cmd" \${java_opts[@]+"\${java_opts[@]}"} -jar "\$jar" \${args[@]+"\${args[@]}"}
EOF
chmod 755 "${PREFIX}/bin/QFM-FI"
