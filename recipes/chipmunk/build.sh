#!/usr/bin/env bash
set -euo pipefail

TOOL_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${TOOL_DIR}" "${PREFIX}/bin"

# Keep a stable filename inside the conda package.
install -m 0644 "chipmunk_v${PKG_VERSION}.jar" "${TOOL_DIR}/chipmunk.jar"

make_wrapper() {
    local exe="$1"
    local main_class="$2"

    cat > "${TOOL_DIR}/${exe}" <<EOF
#!/usr/bin/env bash
set -euo pipefail

case "\${1:-}" in
    -h|--help)
        cat <<'USAGE'
${exe}: wrapper around ChIPMunk.

Examples:
  chipmunk s:sequences.mfa
  chipmunk 7 10 yes oops s:data.mfa
  dichipmunk s:sequences.mfa
  chiphorde 8:10,12:6 mask yes 1.0 s:data.mfa

Set JVM options, for example:
  CHIPMUNK_JAVA_OPTS="-Xms512M -Xmx4G"
USAGE
        exit 0
        ;;
esac

PREFIX_DIR="\${CONDA_PREFIX:-\$(cd "\$(dirname "\$0")/.." && pwd)}"
JAR="\${PREFIX_DIR}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/chipmunk.jar"

java_opts=()
if [[ -n "\${CHIPMUNK_JAVA_OPTS:-}" ]]; then
    # shellcheck disable=SC2206
    java_opts=(\${CHIPMUNK_JAVA_OPTS})
fi

exec java "\${java_opts[@]}" -cp "\${JAR}" ${main_class} "\$@"
EOF

    chmod +x "${TOOL_DIR}/${exe}"
    ln -sf "../share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/${exe}" "${PREFIX}/bin/${exe}"
}

make_wrapper chipmunk ru.autosome.ChIPMunk
make_wrapper dichipmunk ru.autosome.di.ChIPMunk
make_wrapper chiphorde ru.autosome.ChIPHorde
