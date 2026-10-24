#!/bin/bash
# Wrapper for FDRBench. Resolves its own location so the jar is found whatever
# the working directory, and honours JAVA_OPTS for heap size.
set -eu
DIR="$(dirname "$(readlink -f "$0")")"
exec java ${JAVA_OPTS:-} -jar "${DIR}/fdrbench.jar" "$@"
