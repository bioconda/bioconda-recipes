#/bin/bash

mkdir -p ${PREFIX}/bin
rm blobtools
mv lib blobtools
$PYTHON -m pip install . --ignore-installed --no-deps -vv
echo -e "#!/opt/anaconda1anaconda2anaconda3/bin/python\nfrom blobtools.interface import main\nmain()" > ${PREFIX}/bin/blobtools
chmod +x ${PREFIX}/bin/*

echo '#!/usr/bin/env bash' > $PREFIX/bin/blobtools-build_nodesdb
echo "blobtools=$blobtools" >> $PREFIX/bin/blobtools-build_nodesdb
cat $RECIPE_DIR/blobtools-build_nodesdb >> $PREFIX/bin/blobtools-build_nodesdb
chmod +x $PREFIX/bin/blobtools-build_nodesdb
