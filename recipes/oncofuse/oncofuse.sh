#!/bin/bash
# oncofuse executable shell script
set -eu -o pipefail

set -o pipefail
export LC_ALL=en_US.UTF-8

# Find original directory of bash script, resovling symlinks
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

JAR_DIR=$DIR

java=java

if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/java" ]; then
    java="$JAVA_HOME/bin/java"
fi

# Oncofuse 1.1.1 predates the Java 9 module system and breaks on modern JDKs
# (InaccessibleObjectException). Add the required --add-opens flags, but only
# for Java >= 9: Java 8 does not know these options.
java_major=$("$java" -version 2>&1 | head -1 | sed -n 's/.*version "\([0-9]*\).*/\1/p')
if [ "${java_major:-1}" -ge 9 ]; then
    jvm_compat_opts=(--add-opens=java.base/java.lang=ALL-UNNAMED \
        --add-opens=java.base/java.io=ALL-UNNAMED \
        --add-opens=java.base/java.util=ALL-UNNAMED \
        --add-opens=java.base/java.nio=ALL-UNNAMED)
else
    jvm_compat_opts=()
fi

# extract memory and system property Java arguments from the list of provided arguments
# http://java.dzone.com/articles/better-java-shell-script
default_jvm_mem_opts=(-Xms512m -Xmx1g)
jvm_mem_opts=()
jvm_prop_opts=()
pass_args=()
for arg in "$@"; do
    case $arg in
        '-D'*)
            jvm_prop_opts+=("$arg")
            ;;
        '-XX'*)
            jvm_prop_opts+=("$arg")
            ;;
         '-Xm'*)
            jvm_mem_opts+=("$arg")
            ;;
         *)
            pass_args+=("$arg")
            ;;
    esac
done

if [ ${#jvm_mem_opts[@]} -eq 0 ]; then
    jvm_mem_opts=("${default_jvm_mem_opts[@]}")
fi

if [[ ${pass_args[0]:-} == org* ]]
then
    exec "$java" ${jvm_compat_opts[@]+"${jvm_compat_opts[@]}"} \
        ${jvm_mem_opts[@]+"${jvm_mem_opts[@]}"} \
        ${jvm_prop_opts[@]+"${jvm_prop_opts[@]}"} \
        -cp "$JAR_DIR/Oncofuse.jar" ${pass_args[@]+"${pass_args[@]}"}

else
    exec "$java" ${jvm_compat_opts[@]+"${jvm_compat_opts[@]}"} \
        ${jvm_mem_opts[@]+"${jvm_mem_opts[@]}"} \
        ${jvm_prop_opts[@]+"${jvm_prop_opts[@]}"} \
        -jar "$JAR_DIR/Oncofuse.jar" ${pass_args[@]+"${pass_args[@]}"}

fi
