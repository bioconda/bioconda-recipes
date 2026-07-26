#!/bin/bash
set -euo pipefail

# The release ships only the source archive (no pre-built dist), so build from source. The Java deps and
# the VarDict Perl/R helper scripts are provided as pinned `source:` entries (deps/ and vdscripts/), so
# no build-time downloads: compile the jar with javac and assemble the runnable distribution.

outdir="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$outdir/lib" "$outdir/bin" "$PREFIX/bin"

# --- compile the VarDict jar (Java 8 bytecode) ---
if javac --release 8 -version >/dev/null 2>&1; then RELFLAG="--release 8"; else RELFLAG="-source 8 -target 8"; fi
mkdir -p classes
# shellcheck disable=SC2046
javac $RELFLAG -encoding UTF-8 -cp "deps/*" -d classes $(find src/main/java -name '*.java')
jar cfe "$outdir/lib/VarDict-${PKG_VERSION}.jar" com.astrazeneca.vardict.Main -C classes .
cp deps/*.jar "$outdir/lib/"

# --- helper scripts (from the vdscripts source) + launcher ---
scriptdir="$(dirname "$(find vdscripts -name teststrandbias.R | head -1)")"
cp "$scriptdir/teststrandbias.R" "$scriptdir/testsomatic.R" \
   "$scriptdir/var2vcf_valid.pl" "$scriptdir/var2vcf_paired.pl" "$outdir/bin/"
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
