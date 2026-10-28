#!/usr/bin/env bash
set -eu

# Resolve symlinks so the script also works when linked into another bin/.
self="$(readlink -f "$0")"
share="$(dirname "$(dirname "${self}")")/share/@SHARE_NAME@"

cp="${share}/dimont.jar"
for jar in @LIBS@; do
    cp="${cp}:${share}/lib/${jar}"
done

# JVM options (-Xmx4G, -Xms512M, -Dkey=value) may be given before the tool
# arguments, e.g. `dimont -Xmx4G data=peaks.fa position=peak value=signal`.
# JAVA_OPTS and JAVA_TOOL_OPTIONS from the environment are honoured too.
jvm_opts=()
while [ $# -gt 0 ]; do
    case "$1" in
        -Xm[sx]*|-Xss*|-D*) jvm_opts+=("$1"); shift ;;
        *) break ;;
    esac
done

# shellcheck disable=SC2086
exec java ${JAVA_OPTS:-} "${jvm_opts[@]+"${jvm_opts[@]}"}" -cp "${cp}" @MAIN_CLASS@ "$@"
