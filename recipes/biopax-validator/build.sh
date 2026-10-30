#!/bin/bash
set -euxo pipefail

TARGET="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p "${TARGET}" "${PREFIX}/bin"

# Only what the two command line entry points need. The distribution also ships
# biopax-validator-web.war (52 MB, the web application) and a javadoc jar, which
# are not usable from the command line and would triple the package size.
cp -r lib sampleData "${TARGET}/"
cp biopax-validator.jar biopax-validator-client.jar "${TARGET}/"

# Offline validator. It needs the Spring load-time weaving agent, whose file name
# carries the Spring version and therefore changes between validator releases, so
# resolve it by glob at build time instead of pinning the name.
AGENT_JAR="$(basename "$(ls lib/spring-instrument-*.jar)")"
cat > "${PREFIX}/bin/biopax-validator" <<EOF
#!/bin/bash
DIR="\$(cd "\$(dirname "\$(readlink -f "\$0")")/.." && pwd)/share/${PKG_NAME}-${PKG_VERSION}"
exec java \${JAVA_OPTS:-} \\
    --add-opens java.base/java.lang=ALL-UNNAMED \\
    --add-opens java.base/java.lang.reflect=ALL-UNNAMED \\
    -javaagent:"\${DIR}/lib/${AGENT_JAR}" \\
    -Dfile.encoding=UTF-8 \\
    -jar "\${DIR}/biopax-validator.jar" "\$@"
EOF

# Online client, validates through the remote service. No agent required.
cat > "${PREFIX}/bin/biopax-validator-client" <<EOF
#!/bin/bash
DIR="\$(cd "\$(dirname "\$(readlink -f "\$0")")/.." && pwd)/share/${PKG_NAME}-${PKG_VERSION}"
exec java \${JAVA_OPTS:-} -jar "\${DIR}/biopax-validator-client.jar" "\$@"
EOF

chmod +x "${PREFIX}/bin/biopax-validator" "${PREFIX}/bin/biopax-validator-client"
