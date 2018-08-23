#/bin/bash

blobtools=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $blobtools
cp -a ./* $blobtools
cd $blobtools

cd lib
sed -i "s~LIBDIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ''))~LIBDIR = \"$blobtools/lib\"~g" blobtools.py
sed -i "s~SAMTOOLS = os.path.abspath(os.path.join(MAINDIR, 'samtools/bin/samtools'))~SAMTOOLS = \"$PREFIX/bin/samtools\"~g" blobtools.py

cd ..

sed -i -e '4d;16,29d;50d' setup.py
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt

echo "
#!/usr/bin/env bash

if [ ! \$1 = '-h' ]; then

if [ ! -f \"$blobtools/data/nodesDB.txt\" ]; then
echo \"Building blobtools nodesDB...\"
blobtools-build_nodesdb
fi

fi
 
$PYTHON $blobtools/lib/blobtools.py \"\$@\"
" > $PREFIX/bin/blobtools
chmod +x $PREFIX/bin/blobtools

echo '#!/usr/bin/env bash' > $PREFIX/bin/blobtools-build_nodesdb
echo "blobtools=$blobtools" >> $PREFIX/bin/blobtools-build_nodesdb
cat $RECIPE_DIR/blobtools-build_nodesdb >> $PREFIX/bin/blobtools-build_nodesdb
chmod +x $PREFIX/bin/blobtools-build_nodesdb
