#!/bin/bash
mkdir -p "$PREFIX/bin"

cp voyager-cli $PREFIX/bin/
cp voyager-build-cli $PREFIX/bin/
cp voyager-combine-cli $PREFIX/bin/
cp voyager-debug-index $PREFIX/bin/

mkdir -p "$PREFIX/lib"
cp voyager-monitor-0.1.0-SNAPSHOT.jar $PREFIX/lib/

echo '#!/bin/bash' > ${PREFIX}/bin/voyager-monitor
echo 'java -jar "'$PREFIX'/lib/voyager-monitor-1.0.00-SNAPSHOT.jar" "$@"' >> $PREFIX/bin/voyager-monitor
chmod +x "${PREFIX}/bin/voyager-monitor"
