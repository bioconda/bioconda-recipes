#!/bin/bash
# Picard executable shell script. Preserve arguments as data; never eval them.
set -eu -o pipefail

export LC_ALL=en_US.UTF-8

# Find the installation directory, resolving relative and absolute symlinks.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
JAR_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
ENV_PREFIX="$(dirname "$(dirname "$JAR_DIR")")"
java="$ENV_PREFIX/bin/java"
if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/java" ]; then
    java="$JAVA_HOME/bin/java"
fi

jvm_mem_opts=()
jvm_prop_opts=()
pass_args=()
for arg in "$@"; do
    case "$arg" in
        -D*|-XX*) jvm_prop_opts+=("$arg") ;;
        -Xm*)     jvm_mem_opts+=("$arg") ;;
        *)        pass_args+=("$arg") ;;
    esac
done

if [[ -z ${jvm_mem_opts[0]:-} && -z ${_JAVA_OPTIONS+x} ]]; then
    jvm_mem_opts=(-Xms512m -Xmx2g)
fi

# The + form also preserves empty arrays with nounset on older Bash releases.
if [[ ${pass_args[0]:-} == org* ]]; then
    exec "$java" ${jvm_mem_opts[@]+"${jvm_mem_opts[@]}"} \
        ${jvm_prop_opts[@]+"${jvm_prop_opts[@]}"} \
        -cp "$JAR_DIR/picard.jar" ${pass_args[@]+"${pass_args[@]}"}
else
    exec "$java" ${jvm_mem_opts[@]+"${jvm_mem_opts[@]}"} \
        ${jvm_prop_opts[@]+"${jvm_prop_opts[@]}"} \
        -jar "$JAR_DIR/picard.jar" ${pass_args[@]+"${pass_args[@]}"}
fi
