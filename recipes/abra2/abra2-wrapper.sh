#!/bin/bash

jar_name="abra2.jar"
jar_dir=$(dirname "$(pwd -P "${BASH_SOURCE[0]}")")
jar_path="${jar_dir}/${jar_name}"

echo "***** DEBUG START *****"

echo $jar_name
echo $jar_dir
echo $jar_path

echo "***** DEBUG END *****"

if [[ -z "${JAVA_TOOL_OPTIONS}" ]]; then
    JAVA_TOOL_OPTIONS="-Xmx4G"
    export JAVA_TOOL_OPTIONS
fi

java_path="${JAVA_HOME}/bin/java"
[[ -r "${java_path}" ]] || jar_path="java"

exec "${java_path}" -jar ${jar_path} "$@"
