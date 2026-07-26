#!/bin/bash
set -euo pipefail

# The release ships only the source archive (no pre-built dist), so build from source: fetch the pinned
# Java deps from Maven Central and the pinned Perl/R helper scripts from the VarDict submodule commit,
# compile the jar with javac, and assemble the runnable distribution.

VERSION="1.8.4"
outdir="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$outdir/lib" "$outdir/bin" "$PREFIX/bin"

fetch() {  # url  sha256  dest
  curl -L --retry 3 --fail -o "$3" "$1"
  echo "$2  $3" | sha256sum -c -
}

# --- pinned Java dependencies (Maven Central) ---
mkdir -p deps
fetch https://repo1.maven.org/maven2/commons-cli/commons-cli/1.2/commons-cli-1.2.jar \
      e7cd8951956d349b568b7ccfd4f5b2529a8c113e67c32b028f52ffda371259d9 deps/commons-cli-1.2.jar
fetch https://repo1.maven.org/maven2/org/apache/commons/commons-math3/3.6.1/commons-math3-3.6.1.jar \
      1e56d7b058d28b65abd256b8458e3885b674c1d588fa43cd7d1cbb9c7ef2b308 deps/commons-math3-3.6.1.jar
fetch https://repo1.maven.org/maven2/com/github/samtools/htsjdk/2.21.1/htsjdk-2.21.1.jar \
      b11093b94452445a9b0c4212a18fe424632376cff3e4f25fe3afb06226e0eed3 deps/htsjdk-2.21.1.jar
fetch https://repo1.maven.org/maven2/com/edropple/jregex/jregex/1.2_01/jregex-1.2_01.jar \
      fb66a55aecf33337dab0f23ad3821ed2b70aea41c5bd1415059344dccfbbb25a deps/jregex-1.2_01.jar

# --- pinned Perl/R helper scripts (VarDict submodule commit) ---
fetch https://github.com/AstraZeneca-NGS/VarDict/archive/009e017d90b25e497ddd50645dc4fa27c484a193.tar.gz \
      a129e64224f8e2ddfbab89c328719232407cc20cbcf949dd145dd48a7f555d52 vdscripts.tar.gz
mkdir -p vdscripts && tar xzf vdscripts.tar.gz -C vdscripts --strip-components=1

# --- compile the VarDict jar (Java 8 bytecode) ---
if javac --release 8 -version >/dev/null 2>&1; then RELFLAG="--release 8"; else RELFLAG="-source 8 -target 8"; fi
mkdir -p classes
# shellcheck disable=SC2046
javac $RELFLAG -encoding UTF-8 -cp "deps/*" -d classes $(find src/main/java -name '*.java')
jar cfe "$outdir/lib/VarDict-${VERSION}.jar" com.astrazeneca.vardict.Main -C classes .
cp deps/*.jar "$outdir/lib/"

# --- helper scripts + launcher ---
cp vdscripts/teststrandbias.R vdscripts/testsomatic.R vdscripts/var2vcf_valid.pl vdscripts/var2vcf_paired.pl "$outdir/bin/"
cat > "$outdir/bin/vardict-java" <<'LAUNCH'
#!/usr/bin/env bash
# Resolve this script through symlinks (portable: Linux + macOS), then run VarDict.
# JVM defaults keep peak memory bounded (footprint only; override with JAVA_OPTS).
PRG="$0"
while [ -h "$PRG" ]; do
  ls=$(ls -ld "$PRG")
  link=$(expr "$ls" : '.*-> \(.*\)$')
  if expr "$link" : '/.*' > /dev/null; then PRG="$link"; else PRG="$(dirname "$PRG")/$link"; fi
done
APP_HOME="$(cd "$(dirname "$PRG")/.." >/dev/null && pwd -P)"
exec java ${JAVA_OPTS:--Xms768m -Xmx8g -XX:+UseG1GC -XX:+UseStringDeduplication} \
  -classpath "$APP_HOME/lib/*" com.astrazeneca.vardict.Main "$@"
LAUNCH

for exe in vardict-java testsomatic.R teststrandbias.R var2vcf_paired.pl var2vcf_valid.pl; do
  chmod +x "$outdir/bin/$exe"
  ln -s "$outdir/bin/$exe" "$PREFIX/bin/$exe"
done
