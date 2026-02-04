#/bin/bash

rm blobtools
mv lib blobtools

sed -i.bak 's/ lib\./ blobtools./g' blobtools/*py
rm blobtools/*py.bak

$PYTHON -m pip install . --ignore-installed --no-deps -vv

echo '#!/usr/bin/env bash' > $PREFIX/bin/blobtools-build_nodesdb
echo "blobtools=$PREFIX/bin/blobtools" >> $PREFIX/bin/blobtools-build_nodesdb
cat $RECIPE_DIR/blobtools-build_nodesdb >> $PREFIX/bin/blobtools-build_nodesdb
chmod +x $PREFIX/bin/blobtools-build_nodesdb
