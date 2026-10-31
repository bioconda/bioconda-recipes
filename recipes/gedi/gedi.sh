#!/bin/bash
# Gedi launcher (bioconda wrapper).
#
# This wraps the JAR + lib/ that the conda package installs under
# $PREFIX/share/gedi-$VERSION-$BUILDNUM/. It mirrors the option parsing of
# upstream's gedi script (https://github.com/erhard-lab/gedi) but uses the
# conda-installed Java and resolves its install directory without relying
# on `readlink -f` (which is non-portable on older BSD readlink).
set -eu -o pipefail

export LC_ALL=en_US.UTF-8

mem=16G

# Resolve the real directory of this script, following symlinks one hop at
# a time so we work on macOS as well as Linux.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Prefer the conda env's java.
if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/java" ]; then
    java="$JAVA_HOME/bin/java"
elif [ -n "${CONDA_PREFIX:-}" ] && [ -x "$CONDA_PREFIX/bin/java" ]; then
    java="$CONDA_PREFIX/bin/java"
else
    java="java"
fi

CP="$DIR/gedi.jar:$DIR/lib/*:$DIR/plugins/*:$HOME/.gedi/plugins/*"

d=
p=
e=
add="--add-opens java.base/sun.nio.ch=ALL-UNNAMED \
--add-opens java.base/sun.reflect.generics.reflectiveObjects=ALL-UNNAMED \
--add-opens java.xml/com.sun.org.apache.xerces.internal.util=ALL-UNNAMED \
--add-opens java.base/jdk.internal.reflect=ALL-UNNAMED \
--add-opens java.base/jdk.internal.ref=ALL-UNNAMED \
--add-opens java.base/java.lang=ALL-UNNAMED"
tmpfolder=
jmx=

while [[ ${1-} == -* ]]; do
    case $1 in
        -h)
            printf "gedi [-jmx] [-d] [-d2] [-p] [-mem <XYZ>G] [-t <tmpfolder>] [-e] [-<java-option>] main-class [param...]\n\n"
            printf " -d\tStart in debug mode (server on port 8998)\n"
            printf " -d2\tStart in secondary debug mode (server on port 8999)\n"
            printf " -p\tStart cpu hprof\n"
            printf " -t\tspecify tmp folder\n"
            printf " -e\tprepend executables. before main-class\n"
            printf " -mem <XYZ>G\tmaximal memory available to gedi\n\n"
            exit 0
            ;;
        -d)  d=" -agentlib:jdwp=transport=dt_socket,address=8998,server=y";;
        -d2) d=" -agentlib:jdwp=transport=dt_socket,address=8999,server=y";;
        -p)  p=" -Xrunhprof:cpu=samples";;
        -n)  exit 10;;
        -mem) shift; mem="$1";;
        -jmx) jmx="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=8991 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false";;
        -t)  shift
             tmpfolder=" -Djava.io.tmpdir=$1"
             mkdir -p "$1"
             ;;
        -e)  e=executables.;;
        -*)  add="$add $1";;
    esac
    shift
done

exec "$java" $d$p$tmpfolder $jmx $add "-Xmx${mem}" -Xms2048m -cp "$CP" "${e}${1:-}" "${@:2}"
