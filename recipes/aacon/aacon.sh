#!/bin/bash
set -e

JAR_NAME="compbio-conservation.jar"

if [ -x "$JAVA_HOME/bin/java" ]; then
  JAVA=$JAVA_HOME/bin/java
else
  JAVA=$(which java)
fi
$JAVA -jar "$(dirname $(readlink -f "$0"))/$JAR_NAME" "$@"
