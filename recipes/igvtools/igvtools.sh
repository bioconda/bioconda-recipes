#!/bin/bash
# igvtools executable shell script, adapted from VarScan shell script
set -eu -o pipefail

set -o pipefail
export LC_ALL=en_US.UTF-8

# Find original directory of bash script, resovling symlinks
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128
SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Check whether or not to use the bundled JDK
if [ -d "${DIR}/jdk-11" ]; then
    echo echo "Using bundled JDK."
    JAVA_HOME="${DIR}/jdk-11"
    PATH=$JAVA_HOME/bin:$PATH
else
    echo "Using system JDK."
fi

java -Djava.awt.headless=true --module-path="${DIR}/lib" -Xmx1500m --module=org.igv/org.broad.igv.tools.IgvTools "$@"
