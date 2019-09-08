#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin
echo "#!/opt/anaconda1anaconda2anaconda3/bin/python" > $PREFIX/bin/sccaller
cat sccaller_*.py >> $PREFIX/bin/sccaller
chmod 0755 "${PREFIX}/bin/sccaller"
