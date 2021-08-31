#!/bin/bash

jar_name="abra2.jar"
jar_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
jar_path="${jar_dir}/${jar_name}"

if [[ -z "${JAVA_TOOL_OPTIONS}" ]]; then
    JAVA_TOOL_OPTIONS="-Xmx4G"
    export JAVA_TOOL_OPTIONS
fi

java_path="/opt/anaconda1anaconda2anaconda3/bin/java"
[[ -r "${java_path}" ]] || java_path="java"

exec "${java_path}" -jar ${jar_path} "$@"
