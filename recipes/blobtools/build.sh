#/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps -vv
mkdir -p ${PREFIX}/bin
sed -i.bak "s#/usr/bin/env python3#/opt/anaconda1anaconda2anaconda3/bin/python#" blobtools
cp blobtools ${PREFIX}/bin/
chmod a+x ${PREFIX}/bin/blobtools

echo '#!/usr/bin/env bash' > $PREFIX/bin/blobtools-build_nodesdb
echo "blobtools=$blobtools" >> $PREFIX/bin/blobtools-build_nodesdb
cat $RECIPE_DIR/blobtools-build_nodesdb >> $PREFIX/bin/blobtools-build_nodesdb
chmod +x $PREFIX/bin/blobtools-build_nodesdb
